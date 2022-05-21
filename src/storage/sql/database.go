package storage_sql

import (
	"database/sql"
	"fmt"
	"io/ioutil"
	"log"
	"path"

	_ "github.com/lib/pq"
)

type SQLBase struct {
	db *sql.DB
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

func (d *SQLBase) ExecQuery(sqlString string, args []string) ([]string, *sql.Rows, error) {
	interfaces := make([]interface{}, len(args))
	for i := 0; i < len(args); i++ {
		interfaces[i] = args[i]
	}

	rows, err := d.db.Query(sqlString, interfaces...)
	if err != nil {
		return nil, nil, err
	}

	columns, err := rows.Columns()
	if err != nil {
		rows.Close()
		return nil, nil, err
	}
	return columns, rows, nil
}

func (db *SQLBase) ExecFile(command, method string, args []string) ([]string, *sql.Rows, error) {
	sql_path := path.Join("../data/sql", method, command+".sql")
	file, err := ioutil.ReadFile(sql_path)
	if err != nil {
		return nil, nil, err
	}

	columns, rows, err := db.ExecQuery(string(file), args)
	return columns, rows, err
}
