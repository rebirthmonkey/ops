// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package v1

import (
	"github.com/rebirthmonkey/ops/app1/internal/app/apis/user/repo"
)

var _ Service = (*service)(nil)

type Service interface {
	NewUserService() UserService
}

type service struct {
	repo repo.RepoContainer
}

func NewService(repo repo.RepoContainer) Service {
	return &service{repo}
}

func (s *service) NewUserService() UserService {
	return newUserService(s.repo)
}
