package v1

import (
	"errors"
	"github.com/golang-jwt/jwt/v4"
	model "github.com/rebirthmonkey/ops/iam/internal/auth/model/v1"
	authServiceInterface "github.com/rebirthmonkey/ops/iam/internal/auth/service"
	"github.com/rebirthmonkey/ops/iam/internal/user/repo"
	"golang.org/x/crypto/bcrypt"
	"time"
)

var _ authServiceInterface.AuthService = (*service)(nil)

type service struct {
	repo repo.UserRepo
}

func generateToken(username string) (string, error) {
	claims := model.MyClaims{
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * 72)), // Token expires in 72 hours
			Issuer:    "rebirthmonkey",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(model.MySigningKey)
	if err != nil {
		return "", err
	}
	return tokenString, nil
}

func New(repo repo.UserRepo) authServiceInterface.AuthService {
	return &service{
		repo: repo,
	}
}

func (u *service) Login(username, password string) (string, error) {
	user, err := u.repo.Get(username)
	if err != nil || user == nil {
		return "", errors.New("invalid username or password")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password))
	if err != nil {
		return "", errors.New("invalid username or password")
	}

	tokenString, err := generateToken(username)
	if err != nil {
		return "", errors.New("Could not generate token")
	}

	return tokenString, nil
}
