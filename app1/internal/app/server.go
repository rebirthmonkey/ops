package app

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	userCtl "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/controller/gin/v1"
	userRepoMysql "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo/mysql"
	"github.com/rebirthmonkey/ops/pkg/log"
	ginServer "github.com/rebirthmonkey/ops/pkg/server/gin"
	"github.com/rebirthmonkey/ops/pkg/utils"
	ginprometheus "github.com/zsais/go-gin-prometheus"
	"net/http"
)

type Server struct {
	*ginServer.Server
}

func NewServer() (*Server, error) {
	opts := ginServer.NewOptions()

	ginServer, err := ginServer.New(opts)
	if err != nil {
		log.Errorln("Server.New error: ", err)
	}

	s := &Server{
		Server: ginServer,
	}

	s.init()

	return s, nil
}

func (s *Server) init() {
	log.Infoln("[GinServer] Init")

	// 设置 Gin 路由
	s.Engine = gin.Default()

	// 配置CORS，允许所有的请求来源
	s.Engine.Use(cors.Default())

	s.Engine.Use(gin.Logger())

	s.InstallMiddlewares()
	s.InstallAPIs()
}

func (s *Server) InstallMiddlewares() {
	// necessary middlewares
	//s.Use(gin.BasicAuth(gin.Accounts{"foo": "bar", "aaa": "bbb"}))

	//// install custom middlewares
	//for _, m := range s.middlewares {
	//	mw, ok := middleware.Middlewares[m]
	//	if !ok {
	//		log.Warnf("can not find middleware: %s", m)
	//
	//		continue
	//	}
	//
	//	log.Infof("install middleware: %s", m)
	//	s.Use(mw)
	//}
}

func (s *Server) InstallAPIs() {
	if s.Server.Healthz {
		s.Engine.GET("/", func(c *gin.Context) {
			c.String(http.StatusOK, "Healthcheck")
		})
	}

	s.Engine.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message":    "pong",
			"IP Address": utils.GetIPAddress(),
		})
	})

	// 设置Prometheus metrics
	p := ginprometheus.NewPrometheus("gin")
	p.Use(s.Engine)

	v1 := s.Engine.Group("/v1")
	{
		log.Infoln("[Server] registry User Handler")
		userv1 := v1.Group("/users")
		{
			userRepo, err := userRepoMysql.GetUserRepo()
			if err != nil {
				log.Errorln("failed to create Mysql repo: ", err.Error())
			}

			userController := userCtl.New(userRepo)
			userv1.GET("", userController.List)

		}
	}
}

func (s *Server) Run() error {
	s.Engine.Run("0.0.0.0:8888")
	log.Infoln("[Server] Run")

	return s.Server.Run()
}
