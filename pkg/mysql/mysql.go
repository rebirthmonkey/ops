package mysql

import (
	"github.com/rebirthmonkey/ops/pkg/log"
	"gorm.io/gorm"
)

type DB struct {
	*Config
	DBEngine *gorm.DB
}

var dbInstance *DB

func Init() error {
	opts := NewOptions()
	config := NewConfig()

	if err := opts.ApplyTo(config); err != nil {
		log.Errorln("MySQL Init ApplyTo Config Error: ", err)
		return err
	}

	db, err2 := config.New()
	if err2 != nil {
		log.Errorln("MySQL Init Config Error: ", err2)
		return err2
	}

	dbInstance = db
	return nil
}

func GetUniqueDBInstance() *DB {
	if dbInstance == nil {
		log.Errorln("MySQL GetUniqueDBInstance Error: dbInstance is nil")
		panic("MySQL GetUniqueDBInstance Error: dbInstance is nil")
	}
	return dbInstance
}
