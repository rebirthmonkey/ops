package service

type AuthService interface {
	Login(string, string) (string, error)
	//AuthMiddleware() error
}
