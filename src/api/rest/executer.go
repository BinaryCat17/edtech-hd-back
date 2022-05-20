package back_rest

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"path"
	"strings"
)

type RESTQueryExecuter interface {
	Execute(access RESTAccess, sqlString string, args []string) (RESTQueryWriter, error)
}

func (db *SQLBase) Execute(r *http.Request) (RESTQueryWriter, error) {
	args := strings.Split(r.URL.Path, "/")

	if len(args) < 2 {
		return nil, fmt.Errorf("Command not specified")
	}

	method := r.Method
	command := args[1]
	params := args[2:]

	sql_path := path.Join("./queries", method, command+".sql")
	file, err := ioutil.ReadFile(sql_path)
	if err != nil {
		return nil, err
	}

	query, err := db.ExecQuery(string(file), params)
	return &query, err
}
