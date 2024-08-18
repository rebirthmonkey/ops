package auth

import (
	"database/sql"

	"app1/pkg/logging"
)

func Auth(db *sql.DB, name string, password string) bool {
	row := db.QueryRow("SELECT name FROM user WHERE name = ? AND password = ?", name, password)

	var user string
	err := row.Scan(&user)
	if err != nil {
		logging.Logger.Errorln("Auth Error: ", err)
		return false
	}
	return true
}
