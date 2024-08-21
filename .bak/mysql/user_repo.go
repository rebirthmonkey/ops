// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package mysql

import (
	model "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/model/v1"
	userRepoInterface "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo"
	"github.com/rebirthmonkey/ops/pkg/log"
	mysqlDriver "github.com/rebirthmonkey/ops/pkg/mysql"
)

// userRepo stores the user's info.
type userRepo struct {
	DB *mysqlDriver.DB
}

var _ userRepoInterface.UserRepo = (*userRepo)(nil)

// newUserRepo creates and returns a user storage.
func newUserRepo() userRepoInterface.UserRepo {
	db, err := mysqlDriver.Init()
	if err != nil {
		log.Errorln("ConnectMySQL error: ", err)
		panic(err)
	}

	return &userRepo{DB: db}
}

// close closes the repo's DB engine.
func (u *userRepo) close() error {
	return u.DB.Close()
}

// List returns all the related users.
func (u *userRepo) List() (*model.UserList, error) {
	ret := &model.UserList{}

	d := u.DB.DBEngine.
		Order("id desc").
		Find(&ret.Items).
		Offset(-1).
		Limit(-1).
		Count(&ret.TotalCount)

	return ret, d.Error
}
