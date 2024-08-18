package user

import (
	"database/sql"

	"app1/pkg/logging"
)

func GetUserByName(db *sql.DB) []string {
	rows, err := db.Query("SELECT name FROM user")
	if err != nil {
		logging.Logger.Errorln("GetUserByName executing MySQL query error: ", err)
		return nil
	}

	var users []string
	for rows.Next() {
		var user string
		err := rows.Scan(&user)
		if err != nil {
			logging.Logger.Errorln("GetUserByName scanning row error: ", err)
			return nil
		}
		users = append(users, user)
	}
	return users
}
