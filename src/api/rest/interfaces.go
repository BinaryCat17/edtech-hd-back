package api_rest

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

type LoginValidator interface {
	AccesRules(username, password string) (string, error)
}

type QueryExecuter interface {
	Execute(command, method string, args []string) (string, error)
}
