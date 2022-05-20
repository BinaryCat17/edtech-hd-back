package main

import (
	back_sql "edtech/Data/SQL"
)

func main() {
	conf := LoadConfig()

	db := back_sql.NewSQLBase(conf.Database.Host, conf.Database.Port, conf.Database.User, conf.Database.Password, conf.Database.Name)
	defer db.Close()

	// service := NewRestService()
	// service.InitDB()
	// service.Run(":8081")
}
