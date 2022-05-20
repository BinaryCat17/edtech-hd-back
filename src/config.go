package main

import (
	"log"

	"github.com/BurntSushi/toml"
)

type ConfigDatabase struct {
	Host     string
	Port     string
	User     string
	Password string
	Name     string
}

type ConfigServer struct {
	Host string
	Port string
}

type ConfigRule struct {
	Extends string
	GET     []string
	POST    []string
	PUT     []string
	DELETE  []string
}

type Config struct {
	Server      ConfigServer
	Database    ConfigDatabase
	Permissions map[string]ConfigRule
}

func (cfg Config) HasPermissions(user, command, method string) bool {
	if val, ok := cfg.Permissions[user]; ok {
		permitted := []string{}
		switch method {
		case "GET":
			permitted = val.GET
		case "POST":
			permitted = val.POST
		case "PUT":
			permitted = val.PUT
		case "DELETE":
			permitted = val.DELETE
		}

		for _, cmd := range permitted {
			if cmd == command {
				return true
			}
		}

		if val.Extends != "" {
			return cfg.HasPermissions(val.Extends, command, method)
		}
	}
	return false
}

func LoadConfig() Config {
	var conf Config
	_, err := toml.DecodeFile("config.toml", &conf)
	if err != nil {
		log.Fatalln("Can't load config.toml :", err)
	}
	return conf
}
