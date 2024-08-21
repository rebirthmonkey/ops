// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package mysql

import (
	repoContainer "github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo"
	"sync"
)

type repo struct {
	userRepo repoContainer.UserRepo
}

var (
	r    repo
	once sync.Once
)

var _ repoContainer.RepoContainer = (*repo)(nil)

// GetRepo creates and/or returns the store client instance.
func GetRepo() (repoContainer.RepoContainer, error) {
	once.Do(func() {
		r = repo{
			userRepo: newUserRepo(),
		}
	})

	return r, nil
}

// GetUserRepo returns the user store instance.
func (r repo) GetUserRepo() repoContainer.UserRepo {
	return r.userRepo
}

// Close closes the repo.
func (r repo) Close() error {
	return r.Close()
}
