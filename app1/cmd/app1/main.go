package main

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/rebirthmonkey/ops/app1/internal/app"
	ginprometheus "github.com/zsais/go-gin-prometheus"

	"github.com/rebirthmonkey/ops/pkg/utils"
)

func main() {
	//utils.InitConfig()

	app := app.NewApp("app1")

	app.Run()

	// 设置 Gin 路由
	r := gin.Default()

	// 配置CORS，允许所有的请求来源
	r.Use(cors.Default())

	r.Use(gin.Logger())

	// 设置Prometheus metrics
	p := ginprometheus.NewPrometheus("gin")
	p.Use(r)

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, "Healthcheck")
	})

	r.GET("/hello", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message":    "Hello World!",
			"IP Address": utils.GetIPAddress(),
		})
	})

	//r.GET("/users", func(c *gin.Context) {
	//	var users = user.GetUserByName(mysqlDB)
	//
	//	c.JSON(200, gin.H{
	//		"users":      users,
	//		"IP Address": utils.GetIPAddress(),
	//	})
	//})
	//
	//r.GET("/groups", func(c *gin.Context) {
	//	var groups = group.GetGroups(redisDB)
	//
	//	c.JSON(200, gin.H{
	//		"groups":     groups,
	//		"IP Address": utils.GetIPAddress(),
	//	})
	//})

	//r.GET("/auth", func(c *gin.Context) {
	//	user := c.Query("user")
	//	pwd := c.Query("pwd")
	//
	//	isAuthenticated := auth.Auth(mysqlDB, user, pwd)
	//
	//	c.JSON(200, gin.H{
	//		"authenticated": isAuthenticated,
	//	})
	//})

	// 启动 Gin 服务，默认在 0.0.0.0:8080 上启动服务
	r.Run("0.0.0.0:8888")
}
