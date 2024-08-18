package utils

import (
	"flag"
	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
	"io"
	"log"
	"net"
	"os"

	"app1/pkg/logging"
)

func InitConfig() {
	// 定义一个命令行参数 -c 用于指定配置文件
	configPath := flag.String("c", "./configs/config.yaml", "config file path")
	flag.Parse()

	// 使用 Viper 读取配置文件
	viper.SetConfigFile(*configPath)
	if err := viper.ReadInConfig(); err != nil {
		log.Fatalf("Error reading config file, %s", err)
	}

	loggerOut := logging.SetupLogger(viper.GetString("log.filePath"))
	gin.DefaultWriter = io.MultiWriter(loggerOut, os.Stdout, os.Stderr) // 使用Logger的输出
}

func GetIPAddress() string {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		logging.Logger.Fatalln("GetIPAddress error: ", err)
		os.Exit(1)
	}

	for _, address := range addrs {
		// 检查ip地址判断是否回环地址
		if ipnet, ok := address.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {

				return ipnet.IP.String()
			}
		}
	}
	return ""
}
