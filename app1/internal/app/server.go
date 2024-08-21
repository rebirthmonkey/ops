package app

import (
	"github.com/gin-gonic/gin"
	userCtl "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/controller/gin/v1"
	userRepoMysql "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo/mysql"
	"github.com/rebirthmonkey/ops/pkg/log"
	ginServer "github.com/rebirthmonkey/ops/pkg/server/gin"
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
	log.Infoln("[Server] Init")

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
		s.Server.GET("/", func(c *gin.Context) {
			c.String(http.StatusOK, "Healthcheck")
		})
	}

	v1 := s.Server.Engine.Group("/v1")
	{
		log.Infoln("[Server] registry User Handler")
		userv1 := v1.Group("/users")
		{
			userRepoClient, err := userRepoMysql.Repo()
			if err != nil {
				log.Errorln("failed to create Mysql repo: ", err.Error())
			}

			userController := userCtl.NewController(userRepoClient)
			userv1.GET("", userController.List)

		}
	}
}

func (s *Server) Run() error {
	log.Infoln("[Server] Run")

	return s.Server.Run()
}
