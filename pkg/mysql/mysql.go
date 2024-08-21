package mysql

import (
	//"database/sql"
	"gorm.io/gorm"

	"github.com/rebirthmonkey/ops/pkg/log"
)

type DB struct {
	*Config
	//*sql.DB
	DBEngine *gorm.DB
}

func New() (*DB, error) {
	opts := NewOptions()
	config := NewConfig()

	if err := opts.ApplyTo(config); err != nil {
		log.Errorln("MySQL New ApplyTo Config Error: ", err)
		return nil, err
	}

	db, err := config.New()
	if err != nil {
		log.Errorln("MySQL New Config Error: ", err)
		return nil, err
	}

	return db, nil
}

func (db *DB) Run() {
	log.Infoln("[Mysql] Run")
}

func (db *DB) Close() error {
	log.Infoln("[Mysql] Close")
	return nil
}
