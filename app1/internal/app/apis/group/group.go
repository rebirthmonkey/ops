package group

import (
	"context"
	"github.com/go-redis/redis/v8"

	"github.com/rebirthmonkey/ops/pkg/log"
)

func GetGroups(client *redis.Client) []string {
	var groups []string
	var ctx = context.Background()

	groups, err := client.SMembers(ctx, "groupset").Result()
	if err != nil {
		log.Errorln("GetGroups executing Redis query Error: ", err)
		return nil
	}
	return groups
}
