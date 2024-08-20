package user

import (
	"database/sql"

	"github.com/rebirthmonkey/ops/pkg/log"
)

func GetUserByName(db *sql.DB) []string {
	rows, err := db.Query("SELECT name FROM user")
	if err != nil {
		log.Errorln("GetUserByName executing MySQL query error: ", err)
		return nil
	}

	var users []string
	for rows.Next() {
		var user string
		err := rows.Scan(&user)
		if err != nil {
			log.Errorln("GetUserByName scanning row error: ", err)
			return nil
		}
		users = append(users, user)
	}
	return users
}
