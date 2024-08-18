package mysql

import (
	"database/sql"
	"fmt"

	"app1/pkg/logging"
)

func ConnectMySQL(dbHost, dbPort, dbName, dbUser, dbPass string) *sql.DB {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", dbUser, dbPass, dbHost, dbPort, dbName)
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		logging.Logger.Errorln("ConnectMySQL error: ", err, " with dsn: ", dsn)
		panic(err)
	}

	_, err = db.Query("SHOW tables")
	if err != nil {
		logging.Logger.Errorln("ConnectMySQL error: ", err)
		panic(err)
	}
	return db
}
