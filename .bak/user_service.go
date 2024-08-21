// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package v1

import (
	model "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/model/v1"
	"github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo"
	"github.com/rebirthmonkey/ops/pkg/metamodel"
)

// UserService defines functions used to handle user request.
type UserService interface {
	List() (*model.UserList, error)
}

// userService is the UserService instance to handle user request.
type userService struct {
	repo repo.RepoContainer
}

var _ UserService = (*userService)(nil)

// newUserService creates and returns the user service instance.
func newUserService(repo repo.RepoContainer) UserService {
	return &userService{repo}
}

// List returns all the related users.
func (u *userService) List() (*model.UserList, error) {
	users, err := u.repo.UserRepo().List()
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
