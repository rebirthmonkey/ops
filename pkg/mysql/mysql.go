package mysql

import (
	"database/sql"
	"fmt"

	"github.com/rebirthmonkey/ops/pkg/log"
)

func ConnectMySQL(dbHost, dbPort, dbName, dbUser, dbPass string) *sql.DB {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", dbUser, dbPass, dbHost, dbPort, dbName)
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
	return db
}
