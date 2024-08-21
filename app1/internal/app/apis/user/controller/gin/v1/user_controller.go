// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package v1

import (
	"github.com/gin-gonic/gin"
	controllerInterface "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/controller/gin"
	repoInterface "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo"
	serviceInterface "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/service"
	serviceImplemen "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/service/v1"
	"github.com/rebirthmonkey/ops/pkg/log"
	"net/http"
)

var _ controllerInterface.UserController = (*controller)(nil)

type controller struct {
	srv serviceInterface.UserService
}

func New(repo repoInterface.UserRepo) controllerInterface.UserController {
	return &controller{
		srv: serviceImplemen.New(repo),
	}
}

func (u *controller) List(c *gin.Context) {
	log.Infoln("[GinServer] userController: list")

	users, err := u.srv.List()
	if err != nil {
		c.JSON(http.StatusInternalServerError, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"users": users,
	})
}
