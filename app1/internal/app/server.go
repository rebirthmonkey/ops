package app

import (
	"net/http"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	userController "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/controller/gin/v1"
	//userRepoMysql "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo/mysql"
	userRepoRedis "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo/redis"
	"github.com/rebirthmonkey/ops/pkg/log"
	server "github.com/rebirthmonkey/ops/pkg/server/gin"
	"github.com/rebirthmonkey/ops/pkg/utils"
	ginprometheus "github.com/zsais/go-gin-prometheus"
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

	// set Gin log mode
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
		log.Infoln("[GinServer] registry /v1/Users Handler")
		userv1 := v1.Group("/users")
		{
			//userRepo := userRepoMysql.New()
			userRepo := userRepoRedis.New()
			userController := userController.New(userRepo)
			userv1.POST("", userController.Create)
			userv1.DELETE(":name", userController.Delete)
			userv1.PUT(":name", userController.Update)
			userv1.GET(":name", userController.Get)
			userv1.GET("", userController.List)
		}

		//log.Infoln("[GinServer] registry /v1/Groups Handler")
		//groupv1 := v1.Group("/groups")
		//{
		//
		//}
	}
}

func (s *Server) Run() error {
	return s.Server.Run()
}
