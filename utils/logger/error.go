package logger

import (
	"fmt"
	"time"

	customLog "github.com/sirupsen/logrus"
)

//Error logs error level
func Error(content string) {
	content = fmt.Sprintf("%v ", time.Now().Format("15:04:05")) + content

	customLog.SetFormatter(&customLog.TextFormatter{
		DisableTimestamp: true,
	})
	customLog.Errorf(content)
}
