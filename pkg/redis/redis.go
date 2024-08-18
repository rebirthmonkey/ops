package redis

import (
	"context"

	"github.com/go-redis/redis/v8"

	"app1/pkg/logging"
)

func ConnectRedis(redisAddr, redisPassword string, redisDB int) *redis.Client {
	client := redis.NewClient(&redis.Options{
		Addr:     redisAddr,
		Password: redisPassword,
		DB:       redisDB,
	})

	_, err := client.SMembers(context.Background(), "groupset").Result()
	if err != nil {
		logging.Logger.Errorln("ConnectRedis executing Redis query Error: ", err)
		panic(err)
	}
	return client
}
