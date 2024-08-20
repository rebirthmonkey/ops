package mysql

import (
	"database/sql"
	"fmt"
	"github.com/rebirthmonkey/ops/pkg/log"
)

type Config struct {
	Host     string
	Port     int
	Username string
	Password string
	Database string
}

func NewConfig() *Config {
	return &Config{
		Host:     "",
		Port:     0,
		Username: "",
		Password: "",
		Database: "",
	}
}

func (c *Config) New() (*sql.DB, error) {
	//dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", dbUser, dbPass, dbHost, dbPort, dbName)
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", c.Username, c.Password, c.Host, c.Port, c.Database)
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Logger.Errorln("ConnectMySQL error: ", err, " with dsn: ", dsn)
		panic(err)
	}

	_, err = db.Query("SHOW tables")
	if err != nil {
		log.Errorln("ConnectMySQL error: ", err)
		panic(err)
	}
	return db, nil
}
