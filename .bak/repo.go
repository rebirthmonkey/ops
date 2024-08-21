// Copyright 2022 Wukong SUN <rebirthmonkey@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package repo

// RepoContainer defines the storage interface set to combine multiple resource repos.
type RepoContainer interface {
	GetUserRepo() UserRepo
	Close() error
}

//var client RepoContainer
//
//// Client return the store client instance.
//func Client() RepoContainer {
//	return client
//}
//
//// SetClient set the store client.
//func SetClient(c RepoContainer) {
//	client = c
//}
