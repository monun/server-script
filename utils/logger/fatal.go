package logger

import (
	"fmt"
	"time"

	customLog "github.com/sirupsen/logrus"
)

//Fatal logs fatal level
func Fatal(content string) {
	content = fmt.Sprintf("%v ", time.Now().Format("15:04:05")) + content

	customLog.SetFormatter(&customLog.TextFormatter{
		DisableTimestamp: true,
	})
	customLog.Fatalf(content)
}
