// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package v1

import (
	model "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/model/v1"
	"github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo"
	userServiceInterface "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/service"
	"github.com/rebirthmonkey/ops/pkg/metamodel"
)

var _ userServiceInterface.UserService = (*service)(nil)

type service struct {
	repo repo.UserRepo
}

func New(repo repo.UserRepo) userServiceInterface.UserService {
	return &service{
		repo: repo,
	}
}

func (u *service) List() (*model.UserList, error) {
	users, err := u.repo.List()
	if err != nil {
		return nil, err
	}

	infos := make([]*model.User, 0)
	for _, user := range users.Items {
		infos = append(infos, &model.User{
			ObjectMeta: metamodel.ObjectMeta{
				ID:   user.ID,
				Name: user.Name,
				//CreatedAt: user.CreatedAt,
				//UpdatedAt: user.UpdatedAt,
			},
			Nickname: user.Nickname,
			Email:    user.Email,
			Phone:    user.Phone,
		})
	}

	return &model.UserList{ListMeta: users.ListMeta, Items: infos}, nil
}
