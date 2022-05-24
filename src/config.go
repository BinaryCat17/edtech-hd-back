package main

import (
	"log"

	"github.com/BurntSushi/toml"
)

type TOML_Run struct {
	Api     string
	Storage string
}

type TOML_SQL struct {
	Host     string
	Port     string
	User     string
	Password string
	Name     string
}

type TOML_REST struct {
	Host string
	Port string
}

type TOML_Rule struct {
	Extends       []string
	READ_PUBLIC   []string `toml:"read-public"`
	READ_PRIVATE  []string `toml:"read-private"`
	WRITE_PUBLIC  []string `toml:"write-public"`
	WRITE_PRIVATE []string `toml:"write-private"`
}

type TOML_Config struct {
	Run         TOML_Run
	Api_rest    TOML_REST
	Storage_sql TOML_SQL
	Access      map[string]TOML_Rule
}

func LoadConfig() TOML_Config {
	var conf TOML_Config
	_, err := toml.DecodeFile("../data/config.toml", &conf)
	if err != nil {
		log.Fatalln("Can't load config.toml :", err)
	}
	return conf
}

func (cfg *TOML_Config) HasAccess(role string, mode, perms bool, command string) bool {
	if val, ok := cfg.Access[role]; ok {
		permitted := []string{}

		if perms && mode {
			permitted = val.WRITE_PUBLIC
		} else if perms && !mode {
			permitted = val.READ_PUBLIC
		} else if !perms && mode {
			permitted = append(permitted, val.WRITE_PRIVATE...)
			permitted = append(permitted, val.WRITE_PUBLIC...)
		} else if !perms && !mode {
			permitted = append(permitted, val.READ_PRIVATE...)
			permitted = append(permitted, val.READ_PUBLIC...)
		}

		for _, cmd := range permitted {
			if cmd == command {
				return true
			}
		}

		for _, e := range val.Extends {
			if cfg.HasAccess(e, mode, perms, command) {
				return true
			}
		}
	}
	return false
}
