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

	redisDB   *redisDriver.DB
	ginServer *Server
}

func NewApp(name string) *App {
	utils.InitConfig()

	if err := mysqlDriver.Init(); err != nil {
		log.Errorln("Mysql.Init error: ", err)
	}

	opts2 := redisDriver.NewOptions()
	redisDB, err := redisDriver.New(opts2)
	if err != nil {
		log.Errorln("Redis.Init error: ", err)
	}
	defer redisDB.DB.Close() // 确保在程序退出前关闭数据库连接

	//redisDB := redisDriver.ConnectRedis(viper.GetString("redis.addr"), viper.GetString("redis.password"), viper.GetInt("redis.db"))
	//defer redisDB.Close() // 确保在程序退出前关闭数据库连接

	ginServer, err := NewServer()
	if err != nil {
		log.Errorln("NewApp Init Server error: ", err)
	}

	app := &App{
		name:      name,
		redisDB:   redisDB,
		ginServer: ginServer,
	}

	return app
}

// Run is used to launch the application.
func (app *App) Run() {
	log.Infoln("App Run")
	app.ginServer.Run()
}
