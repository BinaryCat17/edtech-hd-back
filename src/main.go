package main

import (
	api_rest "edtech/api/rest"
	storage_sql "edtech/storage/sql"
)

func main() {
	conf := LoadConfig()

	if conf.Run.Api == "rest" && conf.Run.Storage == "sql" {
		db := storage_sql.NewSQLBase(
			conf.Storage_sql.Host,
			conf.Storage_sql.Port,
			conf.Storage_sql.User,
			conf.Storage_sql.Password,
			conf.Storage_sql.Name)
		defer db.Close()

		api_rest.RunServer(conf.Api_rest.Host, conf.Api_rest.Port, &conf, &db, &db, &db)
	}
}
