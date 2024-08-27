package repo

import (
	model "github.com/rebirthmonkey/ops/iam/internal/user/model/v1"
)

type UserRepo interface {
	Create(user *model.User) error
	Delete(username string) error
	Update(user *model.User) error
	Get(username string) (*model.User, error)
	List() (*model.UserList, error)
}
