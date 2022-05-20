package back_rest

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"path"
	"strings"
	"edtech/"
)

type RestService struct {
	db back_sql SQLBase
}

func NewRestService() RestService {
	return RestService{}
}

func (s *RestService) InitDB() {
	s.db = NewSQLBase()
}

func LoadQuery(w http.ResponseWriter, method, command string) (string, error) {
	sql_path := path.Join("./queries", method, command+".sql")
	file, err := ioutil.ReadFile(sql_path)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintln(w, "Can't open query file", sql_path, ":", err)
		return "", err
	}
	return string(file), nil
}

func (s *RestService) InternalError(w http.ResponseWriter, msg string, err error) error {
	w.WriteHeader(http.StatusInternalServerError)
	fmt.Fprintln(w, msg, ":", err)
	return err
}

func (s *RestService) VerifyUserPass(w http.ResponseWriter, r *http.Request) (string, error) {
	file, err := LoadQuery(w, "AUTH", "permissions")
	if err != nil {
		return "", s.InternalError(w, "Permissions query can't load", err)
	}

	user, pass, ok := r.BasicAuth()
	if ok {
		_, rows, err := s.db.ExecQuery(file, []string{user, pass})
		if err != nil {
			return "", s.InternalError(w, "Permissions query can't load", err)
		}
		var permissions string
		if rows.Scan(&permissions) == nil {
			return permissions, nil
		}
	}

	w.Header().Set("WWW-Authenticate", `Basic realm="api"`)
	http.Error(w, "Unauthorized", http.StatusUnauthorized)
	return "", fmt.Errorf("Unauthorized")
}

func AuthorizeCommand(w http.ResponseWriter, r *http.Request, permissions string) (string, []string, error) {
	args := strings.Split(r.URL.Path, "/")

	if len(args) < 2 {
		w.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(w, "Command not specified")
		return "", nil, fmt.Errorf("Command not specified")
	}

	return args[1], args[2:], nil
}

func (s *RestService) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	//permissions, err := s.VerifyUserPass(w, r)
	// if err != nil {
	// 	return
	// }

	args := strings.Split(r.URL.Path, "/")

	if len(args) < 2 {
		w.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(w, "Command not specified")
		return
	}

	command := args[1]

	file, err := LoadQuery(w, r.Method, command)
	if err != nil {
		return
	}

	if r.Method == "GET" {
		query, err := s.db.JSONQuery(string(file), args[2:])
		if err != nil {
			s.InternalError(w, "Error JSONQuery "+command, err)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(query)

	} else if r.Method == "POST" || r.Method == "PUT" || r.Method == "DELETE" {
		s.db.EmptyQuery(string(file), args[2:])

		if err != nil {
			s.InternalError(w, "Error EmptyQuery "+command, err)
			return
		}
	} else {
		w.WriteHeader(http.StatusMethodNotAllowed)
	}

}

func (s *RestService) Run(addr string) {
	defer s.db.close()

	// r := mux.NewRouter()

	if err := http.ListenAndServe(addr, s); err != nil {
		log.Fatalln("Serve error: ", err)
	}
}
