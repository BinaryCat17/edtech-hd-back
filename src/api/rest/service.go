package api_rest

import (
	"errors"
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strings"
	"time"

	"github.com/google/uuid"
)

type RestService struct {
	AccessValidator
	LoginValidator
	QueryExecuter
	SessionValidator
}

type QueryProcess struct {
	Username string
	Target   string
	Role     string
	Access   bool
	Method   string
	Command  string
	Args     []string
}

func (s *RestService) AuthorizeQuery(w http.ResponseWriter, r *http.Request) (*QueryProcess, error) {
	var query QueryProcess
	query.Role = "unauthorized"
	user, pass, ok := r.BasicAuth()

	if ok {
		query.Username = user
		role, err := s.LoginValidator.AccesRules(user, pass)
		if err != nil {
			return nil, err
		}
		query.Role = role
		sessionToken := uuid.NewString()
		expiresAt := time.Now().Add(48 * time.Hour)
		if s.SessionValidator.Authorize(user, sessionToken, expiresAt) == nil {
			http.SetCookie(w, &http.Cookie{
				Name:    "session_token",
				Value:   sessionToken,
				Path:    "/",
				Expires: expiresAt,
			})
		}
		return nil, nil
	}

	c, err := r.Cookie("session_token")
	if err != nil {
		return nil, err
	}

	username, role := s.SessionValidator.IsAuthorized(c.Value)
	if len(username) == 0 {
		return nil, errors.New("unauthorized")
	} else {
		query.Role = role
		query.Username = username
	}

	return &query, nil
}

func (q *QueryProcess) ParseMethod(r *http.Request) error {
	switch r.Method {
	case "GET":
		q.Access = AccessRead
		q.Method = "READ"
	case "POST":
		q.Access = AccessWrite
		q.Method = "WRITE"
	default:
		return errors.New("method not allowed")
	}
	return nil
}

func (q *QueryProcess) ParseCommand(user string) error {
	if len(q.Args) < 3 {
		return errors.New("command not specified")
	}

	q.Command = q.Args[2]
	if len(q.Args) == 3 {
		q.Target = user
	} else {
		q.Target = q.Args[3]
	}

	q.Args = q.Args[3:]
	return nil
}

func Proxy(targetUrl string, w http.ResponseWriter, r *http.Request) {
	var target *url.URL
	target, err := url.Parse(targetUrl)
	if err != nil {
		return
	}

	origHost := target.Host
	origScheme := target.Scheme
	d := func(req *http.Request) {
		req.URL.Host = origHost
		req.URL.Scheme = origScheme
	}

	p := &httputil.ReverseProxy{Director: d}
	p.ServeHTTP(w, r)
}

func (s *RestService) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method == "OPTIONS" {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

		w.WriteHeader(http.StatusOK)
		return
	}

	q, err := s.AuthorizeQuery(w, r)
	if err != nil {
		http.Redirect(w, r, "http://чёрныйящик.рф/signin", http.StatusSeeOther)
		return
	}

	if q == nil {
		http.Redirect(w, r, "http://чёрныйящик.рф/home", http.StatusSeeOther)
		return
	}

	q.Args = strings.Split(r.URL.Path, "/")
	if q.Args[1] == "app" {
		Proxy("http://192.168.88.250:8081", w, r)
		return
	}

	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	if q.Args[1] != "api" {
		http.Error(w, "Что тебе нужно от меня, друг?", http.StatusNotFound)
		return
	}

	err = q.ParseMethod(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusMethodNotAllowed)
		return
	}

	err = q.ParseCommand(q.Username)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	if !s.AccessValidator.HasAccess(q.Role, q.Access, q.Username != q.Target, q.Command) {
		http.Error(w, "No rights to execute the command", http.StatusForbidden)
		return
	}

	if q.Command == "save-file" {
		err = uploadFile(r, q.Username)
		if err != nil {
			fmt.Println(err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		} else {
			w.WriteHeader(http.StatusOK)
			return
		}
	}

	if q.Command == "get-file" {
		if len(q.Args) < 2 {
			http.Error(w, "file name or user name not specified", http.StatusBadRequest)
		} else {
			http.ServeFile(w, r, "../data/users/"+q.Args[0]+"/"+q.Args[1])
		}
		return
	}

	res, err := s.QueryExecuter.Execute(q.Command, q.Method, q.Args)
	if err != nil {
		fmt.Println(err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, res)
}

func RunServer(addr, port string,
	access AccessValidator, login LoginValidator, query QueryExecuter, session SessionValidator) {

	s := &RestService{access, login, query, session}
	if err := http.ListenAndServe(addr+":"+port, s); err != nil {
		log.Fatalln("Server fatal error: ", err)
	}
}
