// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package repo

import (
	model "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/model/v1"
)

// UserRepo defines the user resources.
type UserRepo interface {
	List() (*model.UserList, error)
}
