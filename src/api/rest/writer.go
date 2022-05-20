package back_rest

import (
	"encoding/json"
	"net/http"
)

type RESTQueryWriter interface {
	Write(w http.ResponseWriter) error
}

func (q *SQLQuery) Write(w http.ResponseWriter) error {
	count := len(q.columns)
	tableData := make([]map[string]interface{}, 0)
	values := make([]interface{}, count)
	valuePtrs := make([]interface{}, count)
	for i := 0; i < count; i++ {
		valuePtrs[i] = &values[i]
	}

	for q.rows.Next() {
		err := q.rows.Scan(valuePtrs...)
		if err != nil {
			return err
		}

		entry := make(map[string]interface{})
		for i, col := range q.columns {
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

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	return json.NewEncoder(w).Encode(tableData)
}
