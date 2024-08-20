package redis

import (
	"github.com/go-redis/redis/v8"

	"github.com/rebirthmonkey/ops/pkg/log"
)

type DB struct {
	*Config
	DB *redis.Client
}

func New(opts *Options) (*DB, error) {
	config := NewConfig()

	if err := opts.ApplyTo(config); err != nil {
		log.Errorln("Redis New ApplyTo Config Error: ", err)
		return nil, err
	}

	db, err := config.New()
	if err != nil {
		log.Errorln("Redis New Config Error: ", err)
		return nil, err
	}

	return &DB{
		Config: config,
		DB:     db,
	}, nil
}

func (db *DB) Run() {
	log.Infoln("[Redis] Run")
}
