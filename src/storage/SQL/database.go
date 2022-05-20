package back_sql

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

type SQLBase struct {
	db *sql.DB
}

type SQLQuery struct {
	columns []string
	rows    *sql.Rows
}

func NewSQLBase(dHost, dPort, dUser, dPassword, dName string) SQLBase {
	psqlconn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable", dHost, dPort, dUser, dPassword, dName)
	db, err := sql.Open("postgres", psqlconn)

	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
		return SQLBase{}
	}

	err = db.Ping()
	if err != nil {
		log.Fatalf("Unable to ping database: %v\n", err)
	}

	return SQLBase{db}
}

func (d *SQLBase) Close() {
	d.db.Close()
}

func (d *SQLBase) ExecQuery(sqlString string, args []string) (SQLQuery, error) {
	interfaces := make([]interface{}, len(args))
	for i := 0; i < len(args); i++ {
		interfaces[i] = args[i]
	}

	rows, err := d.db.Query(sqlString, interfaces...)
	if err != nil {
		return SQLQuery{nil, nil}, err
	}

	columns, err := rows.Columns()
	if err != nil {
		rows.Close()
		return SQLQuery{nil, nil}, err
	}
	return SQLQuery{columns, rows}, nil
}
