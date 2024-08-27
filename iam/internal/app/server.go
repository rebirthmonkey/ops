package app

import (
	//usedUserRepo "github.com/rebirthmonkey/ops/iam/internal/user/repo/mq"
	usedUserRepo "github.com/rebirthmonkey/ops/iam/internal/user/repo/mysql"
	"net/http"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	ginprometheus "github.com/zsais/go-gin-prometheus"

	userController "github.com/rebirthmonkey/ops/iam/internal/user/controller/gin/v1"
	"github.com/rebirthmonkey/ops/pkg/log"
	server "github.com/rebirthmonkey/ops/pkg/server/gin"
	"github.com/rebirthmonkey/ops/pkg/utils"

	authController "github.com/rebirthmonkey/ops/iam/internal/auth/controller/gin/v1"
)

type Server struct {
	*server.Server
}

func NewServer() (*Server, error) {
	ginServer, err := server.New()
	if err != nil {
		log.Errorln("GinServer.New error: ", err)
	}

	s := &Server{
		Server: ginServer,
	}

	s.init()

	return s, nil
}

func (s *Server) init() {
	log.Infoln("[GinServer] Init")

	gin.SetMode(gin.ReleaseMode)

	s.Engine = gin.Default()
	s.Engine.Use(cors.Default())
	s.Engine.Use(gin.Logger())

	s.installMiddlewares()
	s.installAPIs()
}

func (s *Server) installMiddlewares() {
	log.Infoln("[GinServer] Install Middlewares")
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

func (s *Server) installAPIs() {
	log.Infoln("[GinServer] Install APIs")

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

	p := ginprometheus.NewPrometheus("gin")
	p.Use(s.Engine)

	v1 := s.Engine.Group("/v1")
	{
		log.Infoln("[GinServer] registry /v1/Auth Handler")
		authv1 := v1.Group("/auth")
		{
			userRepo := usedUserRepo.New()
			authControllerInstance := authController.New(userRepo)
			authv1.POST("/login", authControllerInstance.Login)
		}

		log.Infoln("[GinServer] registry /v1/Users Handler")
		secureUserv1 := v1.Group("/users")
		{
			userRepo := usedUserRepo.New()

			authControllerInstance := authController.New(userRepo)
			secureUserv1.Use(authControllerInstance.AuthMiddleware)

			userControllerInstance := userController.New(userRepo)
			secureUserv1.POST("", userControllerInstance.Create)
			secureUserv1.DELETE(":name", userControllerInstance.Delete)
			secureUserv1.PUT(":name", userControllerInstance.Update)
			secureUserv1.GET(":name", userControllerInstance.Get)
			secureUserv1.GET("", userControllerInstance.List)
		}
	}
}

func (s *Server) Run() error {
	return s.Server.Run()
}
