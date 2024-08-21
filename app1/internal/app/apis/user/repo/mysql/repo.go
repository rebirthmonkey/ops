// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package mysql

import (
	model "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/model/v1"
	userRepoInterface "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo"
	mysqlDriver "github.com/rebirthmonkey/ops/pkg/mysql"
	"sync"
)

var _ userRepoInterface.UserRepo = (*repo)(nil)

type repo struct {
	DB *mysqlDriver.DB
}

var (
	r    repo
	once sync.Once
)

// GetUserRepo creates and/or returns the store client instance.
func GetUserRepo() (userRepoInterface.UserRepo, error) {
	once.Do(func() {
		db := mysqlDriver.GetDB()

		r = repo{
			DB: db,
		}
	})

	return &r, nil
}

func (u *repo) List() (*model.UserList, error) {
	ret := &model.UserList{}

	d := u.DB.DBEngine.
		Order("id desc").
		Find(&ret.Items).
		Offset(-1).
		Limit(-1).
		Count(&ret.TotalCount)

	return ret, d.Error
}

func (u *repo) Close() error {
	return u.DB.Close()
}
