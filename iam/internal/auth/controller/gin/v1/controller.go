package v1

import (
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
	controllerInterface "github.com/rebirthmonkey/ops/iam/internal/auth/controller/gin"
	model "github.com/rebirthmonkey/ops/iam/internal/auth/model/v1"
	serviceInterface "github.com/rebirthmonkey/ops/iam/internal/auth/service"
	serviceImpl "github.com/rebirthmonkey/ops/iam/internal/auth/service/v1"
	repoInterface "github.com/rebirthmonkey/ops/iam/internal/user/repo"
	"github.com/rebirthmonkey/ops/pkg/server/gin/util"
	"net/http"
)

var _ controllerInterface.AuthController = (*controller)(nil)

type controller struct {
	svc serviceInterface.AuthService
}

func New(repo repoInterface.UserRepo) controllerInterface.AuthController {
	return &controller{
		svc: serviceImpl.New(repo),
	}
}

func (u *controller) Login(c *gin.Context) {
	var loginParams struct {
		Username string `form:"username"`
		Password string `form:"password"`
	}

	if err := c.ShouldBind(&loginParams); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request parameters"})
		return
	}

	tokenString, err := u.svc.Login(loginParams.Username, loginParams.Password)
	if err != nil {
		util.WriteResponse(c, err, nil)
		return
	}

	util.WriteResponse(c, nil, tokenString)
}

func (u *controller) AuthMiddleware(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is required"})
	}

	token, err := jwt.ParseWithClaims(authHeader, &model.MyClaims{}, func(token *jwt.Token) (interface{}, error) {
		return model.MySigningKey, nil
	})

	if err != nil || !token.Valid {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}

	if claims, ok := token.Claims.(*model.MyClaims); ok {
		c.Set("username", claims.Username)
	} else {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
		return
	}

	c.Next()
}
