package logger

import (
	"fmt"
	"time"

	"github.com/mattn/go-colorable"
	customLog "github.com/sirupsen/logrus"
)

//Fatal logs fatal level
func Fatal(content string) {
	content = fmt.Sprintf("%v ", time.Now().Format("15:04:05")) + content

	customLog.SetFormatter(&customLog.TextFormatter{
		ForceColors:      true,
		DisableTimestamp: true,
	})
	customLog.SetOutput(colorable.NewColorableStdout())
	customLog.Fatalf(content)
}
