package mysql

import (
	"database/sql"

	"github.com/rebirthmonkey/ops/pkg/log"
)

type DB struct {
	*Config
	*sql.DB
}

func New(opts *Options) (*DB, error) {
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

	return &DB{
		Config: config,
		DB:     db,
	}, nil
}

func (db *DB) Run() {
	log.Infoln("[Mysql] Run")
}
