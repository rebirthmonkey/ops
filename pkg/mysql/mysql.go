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

func GetDB() *DB {
	if dbInstance == nil {
		log.Errorln("MySQL GetDB Error: dbInstance is nil")
		panic("MySQL GetDB Error: dbInstance is nil")
	}
	return dbInstance
}

func (db *DB) Close() error {
	log.Infoln("[Mysql] Close")
	return nil
}
