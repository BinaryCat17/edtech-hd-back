package api_rest

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"strings"
)

type RestService struct {
	AccessValidator
	LoginValidator
	QueryExecuter
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

func (s *RestService) AuthorizeQuery(r *http.Request) (*QueryProcess, error) {
	var query QueryProcess
	user, pass, ok := r.BasicAuth()

	if ok {
		query.Username = user
		role, err := s.LoginValidator.AccesRules(user, pass)
		if err != nil {
			return nil, err
		}
		query.Role = role

	} else {
		query.Role = "unauthorized"
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

func (q *QueryProcess) ParseCommand(r *http.Request) error {
	q.Args = strings.Split(r.URL.Path, "/")

	if len(q.Args) < 3 || q.Args[1] != "command" {
		return errors.New("command not specified")
	}

	q.Command = q.Args[2]
	q.Target = q.Args[3]
	q.Args = q.Args[3:]
	return nil
}

func (s *RestService) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	q, err := s.AuthorizeQuery(r)
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

	err = q.ParseCommand(r)
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
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(res)
}

func RunServer(addr, port string,
	access AccessValidator, login LoginValidator, query QueryExecuter) {

	s := &RestService{access, login, query}
	if err := http.ListenAndServe(addr+":"+port, s); err != nil {
		log.Fatalln("Server fatal error: ", err)
	}
}
