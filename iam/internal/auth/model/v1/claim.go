package v1

import "github.com/golang-jwt/jwt/v4"

var MySigningKey = []byte("secret")

type MyClaims struct {
	jwt.RegisteredClaims
	Username string `json:"username"`
}
