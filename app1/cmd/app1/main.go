package main

import (
	"github.com/rebirthmonkey/ops/app1/internal/app"
)

func main() {
	app := app.NewApp("app1")
	app.Run()
}
