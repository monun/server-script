package logger

import (
	"fmt"
	"time"

	"github.com/mattn/go-colorable"
	customLog "github.com/sirupsen/logrus"
)

//Error logs error level
func Error(content string) {
	content = fmt.Sprintf("%v ", time.Now().Format("15:04:05")) + content

	customLog.SetFormatter(&customLog.TextFormatter{
		ForceColors:      true,
		DisableTimestamp: true,
	})
	customLog.SetOutput(colorable.NewColorableStdout())
	customLog.Errorf(content)
}
