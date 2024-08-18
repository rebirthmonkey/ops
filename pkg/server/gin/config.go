package gin

import (
	"github.com/gin-gonic/gin"
)

type Config struct {
	Address     string
	Mode        string
	Middlewares []string
	Healthz     bool
}

func NewConfig() *Config {
	return &Config{
		Address:     ":8080",
		Healthz:     true,
		Mode:        gin.ReleaseMode,
		Middlewares: []string{},
	}
}

func (c Config) NewServer() (*Server, error) {
	gin.SetMode(c.Mode)

	s := &Server{
		Address:     c.Address,
		Healthz:     c.Healthz,
		Middlewares: c.Middlewares,
		Engine:      gin.New(),
	}

	s.init()
	return s, nil
}
