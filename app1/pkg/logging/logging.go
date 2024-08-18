package logging

import (
	"io"
	"os"

	"github.com/sirupsen/logrus"
)

var Logger *logrus.Logger

func SetupLogger(logFilePath string) io.Writer {
	//logFilePath := viper.GetString(logFilePathKey)
	logFile, err := os.OpenFile(logFilePath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		logrus.Fatalf("Failed to open log file %s for output: %s", logFilePath, err)
		return nil
	}

	Logger = logrus.New()
	Logger.Formatter = &logrus.JSONFormatter{} // 设置为JSON格式
	Logger.Out = logFile
	return Logger.Out
}
