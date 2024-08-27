package gin

import "github.com/gin-gonic/gin"

type AuthController interface {
	Login(c *gin.Context)
	AuthMiddleware(c *gin.Context)
}
