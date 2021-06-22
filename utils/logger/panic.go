package logger

import (
	"fmt"
	"time"

	customLog "github.com/sirupsen/logrus"
)

//Panic logs panic level
func Panic(content string) {
	content = fmt.Sprintf("%v ", time.Now().Format("15:04:05")) + content

	customLog.SetFormatter(&customLog.TextFormatter{
		DisableTimestamp: true,
	})
	customLog.Panicf(content)
}
