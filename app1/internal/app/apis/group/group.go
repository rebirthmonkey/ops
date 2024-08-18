package group

import (
	"context"
	"github.com/go-redis/redis/v8"

	"app1/pkg/logging"
)

func GetGroups(client *redis.Client) []string {
	var groups []string
	var ctx = context.Background()

	groups, err := client.SMembers(ctx, "groupset").Result()
	if err != nil {
		logging.Logger.Errorln("GetGroups executing Redis query Error: ", err)
		return nil
	}
	return groups
}
