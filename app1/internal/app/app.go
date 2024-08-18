package app

import (
	"database/sql"
	"github.com/go-redis/redis/v8"
	"github.com/spf13/viper"

	"github.com/rebirthmonkey/ops/pkg/log"
	mysqlDriver "github.com/rebirthmonkey/ops/pkg/mysql"
	redisDriver "github.com/rebirthmonkey/ops/pkg/redis"
	"github.com/rebirthmonkey/ops/pkg/utils"
)

// App is the main structure of a cli application.
// It is recommended that an app be created with the app.NewApp() function.
type App struct {
	name        string
	description string

	mysqlDB *sql.DB
	redisDB *redis.Client
}

// NewApp creates a new application instance based on the given application name
func NewApp(name string) *App {
	a := &App{
		name: name,
	}

	utils.InitConfig()

	mysqlDB := mysqlDriver.ConnectMySQL(viper.GetString("mysql.host"), viper.GetString("mysql.port"), viper.GetString("mysql.dbname"), viper.GetString("mysql.user"), viper.GetString("mysql.password"))
	defer mysqlDB.Close() // 确保在程序退出前关闭数据库连接

	redisDB := redisDriver.ConnectRedis(viper.GetString("redis.addr"), viper.GetString("redis.password"), viper.GetInt("redis.db"))
	defer redisDB.Close() // 确保在程序退出前关闭数据库连接

	return a
}

// Run is used to launch the application.
func (a *App) Run() {
	log.Infoln("App Run")
}
