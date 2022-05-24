package api_rest

import (
	"errors"
	"fmt"
	"log"
	"net/http"
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
			fmt.Println("Setting cookie ", user, sessionToken, expiresAt)
			http.SetCookie(w, &http.Cookie{
				Name:    "session_token",
				Value:   sessionToken,
				Path:    "/",
				Expires: expiresAt,
			})
		}
	} else {
		c, err := r.Cookie("session_token")
		if err != nil {
			return nil, err
		}

		username, role := s.SessionValidator.IsAuthorized(c.Value)
		fmt.Println(username, role)
		if len(username) == 0 {
			return nil, errors.New("unauthorized")
		} else {
			query.Role = role
			query.Username = username
		}
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

func (q *QueryProcess) ParseCommand(r *http.Request, user string) error {
	q.Args = strings.Split(r.URL.Path, "/")

	if len(q.Args) < 3 || q.Args[1] != "api" {
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

func (s *RestService) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	fmt.Println(r.URL)
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	q, err := s.AuthorizeQuery(w, r)
	if err != nil {
		w.Header().Set("WWW-Authenticate", `Basic realm="api"`)
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	err = q.ParseMethod(r)
	if err != nil {
		http.Error(w, err.Error(), http.StatusMethodNotAllowed)
		return
	}

	err = q.ParseCommand(r, q.Username)
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	if !s.AccessValidator.HasAccess(q.Role, q.Access, q.Username != q.Target, q.Command) {
		http.Error(w, "No rights to execute the command", http.StatusForbidden)
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
