package app

import (
	"github.com/rebirthmonkey/ops/pkg/log"
	mysqlDriver "github.com/rebirthmonkey/ops/pkg/mysql"
	redisDriver "github.com/rebirthmonkey/ops/pkg/redis"
	"github.com/rebirthmonkey/ops/pkg/utils"
)

type App struct {
	name        string
	description string

	ginServer *Server
}

func New(name string) *App {
	utils.InitConfig()

	if err := mysqlDriver.Init(); err != nil {
		log.Errorln("Mysql.Init error: ", err)
	}

	if err := redisDriver.Init(); err != nil {
		log.Errorln("Redis.Init error: ", err)
	}

	//if err := restDriver.Init(); err != nil {
	//	log.Errorln("REST.Init error: ", err)
	//}

	ginServer, err := NewServer()
	if err != nil {
		log.Errorln("GinServer.Init Server error: ", err)
	}

	app := &App{
		name:      name,
		ginServer: ginServer,
	}

	return app
}

func (app *App) Run() {
	log.Infoln("App Run")
	app.ginServer.Run()
}
