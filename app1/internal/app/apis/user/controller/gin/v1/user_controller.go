// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package v1

import (
	"errors"
	"github.com/gin-gonic/gin"
	controllerInterface "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/controller/gin"
	model "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/model/v1"
	repoInterface "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo"
	serviceInterface "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/service"
	serviceImpl "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/service/v1"
	"github.com/rebirthmonkey/ops/pkg/log"
	"github.com/rebirthmonkey/ops/pkg/server/gin/util"
)

var _ controllerInterface.UserController = (*controller)(nil)

type controller struct {
	svc serviceInterface.UserService
}

func New(repo repoInterface.UserRepo) controllerInterface.UserController {
	return &controller{
		svc: serviceImpl.New(repo),
	}
}

func (u *controller) Create(c *gin.Context) {
	log.Infoln("[GinServer] userController: create")

	var user model.User

	if err := c.ShouldBindJSON(&user); err != nil {
		log.Errorln("User.Controller.Create ErrBind")
		util.WriteResponse(c, errors.New("User.Controller.Create ErrBind"), nil)

		return
	}

	if err := u.svc.Create(&user); err != nil {
		util.WriteResponse(c, err, nil)
		return
	}

	util.WriteResponse(c, nil, user)
}

func (u *controller) Delete(c *gin.Context) {
	log.Infoln("[GinServer] userController: delete")

	if err := u.svc.Delete(c.Param("name")); err != nil {
		util.WriteResponse(c, err, nil)
		return
	}

	var msg string = "deleted user " + c.Param("name")
	util.WriteResponse(c, nil, msg)
}

func (u *controller) Update(c *gin.Context) {
	log.Infoln("[GinServer] userController: update")

	var user model.User

	if err := c.ShouldBindJSON(&user); err != nil {
		log.Errorln("User.Controller.Update ErrBind", err)
		util.WriteResponse(c, errors.New("User.Controller.Update ErrBind"), nil)
		return
	}

	user.Name = c.Param("name")

	if err := u.svc.Update(&user); err != nil {
		util.WriteResponse(c, err, nil)
		return
	}

	util.WriteResponse(c, nil, user)
}

func (u *controller) Get(c *gin.Context) {
	log.Infoln("[GinServer] userController: get")

	user, err := u.svc.Get(c.Param("name"))
	if err != nil {
		util.WriteResponse(c, err, nil)
		return
	}

	util.WriteResponse(c, nil, user)
}

func (u *controller) List(c *gin.Context) {
	log.Infoln("[GinServer] userController: list")

	users, err := u.svc.List()
	if err != nil {
		util.WriteResponse(c, err, nil)
		return
	}

	util.WriteResponse(c, nil, users)
}
