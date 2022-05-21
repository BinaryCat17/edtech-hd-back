package storage_sql

import (
	"encoding/json"
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
	_, rows, err := db.ExecFile("access", "AUTH", []string{username, password})
	if err != nil {
		return "", err
	}

	var permissions string
	err = rows.Scan(&permissions)
	return permissions, err
}
