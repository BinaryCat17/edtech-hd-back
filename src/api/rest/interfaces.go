package api_rest

import (
	"time"
)

const (
	AccessRead  = false
	AccessWrite = true
)

const (
	AccessPrivate = false
	AccessPublic  = true
)

type AccessValidator interface {
	HasAccess(role string, mode, perms bool, command string) bool
}

type SessionValidator interface {
	IsAuthorized(token string) (string, string)

	Authorize(username, token string, expires time.Time) error
}

type LoginValidator interface {
	AccesRules(username, password string) (string, error)
}

type QueryExecuter interface {
	Execute(command, method string, args []string) (string, error)
}
