package logger

import (
	"fmt"
	"time"

	customLog "github.com/sirupsen/logrus"
)

//Info logs information level
func Info(content string) {
	content = fmt.Sprintf("%v ", time.Now().Format("15:04:05")) + content

	customLog.SetFormatter(&customLog.TextFormatter{
		DisableTimestamp: true,
	})
	customLog.Infof(content)
}
