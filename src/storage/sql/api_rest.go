package storage_sql

import (
	"encoding/json"
	"fmt"
	"time"
)

func (db *SQLBase) Execute(command, method string, args []string) (string, error) {
	columns, rows, err := db.ExecFile(command, method, args)

	if err != nil {
		return "", err
	}

	if method != "READ" && method != "AUTH" {
		return "", nil
	}

	count := len(columns)
	tableData := make([]map[string]interface{}, 0)
	values := make([]interface{}, count)
	valuePtrs := make([]interface{}, count)
	for i := 0; i < count; i++ {
		valuePtrs[i] = &values[i]
	}

	for rows.Next() {
		err := rows.Scan(valuePtrs...)
		if err != nil {
			return "", err
		}

		entry := make(map[string]interface{})
		for i, col := range columns {
			var v interface{}
			val := values[i]
			b, ok := val.([]byte)
			if ok {
				v = string(b)
			} else {
				v = val
			}
			entry[col] = v
		}
		tableData = append(tableData, entry)
	}

	j, err := json.Marshal(tableData)
	if err != nil {
		return "", err
	}
	return string(j), nil
}

func (db *SQLBase) AccesRules(username, password string) (string, error) {
	_, rows, err := db.ExecQuery("SELECT access FROM users WHERE username=$1 AND password=$2;", []string{username, password})
	if err != nil {
		return "", err
	}

	var permissions string
	rows.Next()
	err = rows.Scan(&permissions)
	return permissions, err
}

func (db *SQLBase) IsAuthorized(token string) (string, string) {
	_, rows, err := db.ExecQuery(
		"SELECT u.username, u.access, s.expires FROM sessions s, users u WHERE u.username = s.username AND s.token=$1;",
		[]string{token})
	if err != nil {
		fmt.Println(err)
		return "", ""
	}

	var username, role string
	var expiresTime time.Time
	rows.Next()
	err = rows.Scan(&username, &role, &expiresTime)
	if err != nil {
		return "", ""
	}

	if expiresTime.Before(time.Now()) {
		db.db.Query(
			"DELETE FROM sessions WHERE token=$1;",
			token)
		return "", ""
	}

	return username, role
}

func (db *SQLBase) Authorize(username, token string, expires time.Time) error {
	db.db.Query(
		"DELETE FROM sessions WHERE username=$1;",
		username)
	_, err := db.db.Query(
		"INSERT INTO sessions (username, token, expires) VALUES ($1, $2, $3)",
		username, token, expires)
	return err
}
