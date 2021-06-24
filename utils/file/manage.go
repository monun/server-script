package file

import (
	"monun/server-script/utils/logger"
	"os"
)

func CheckFolderExist(path string) {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		logger.Warn("Generating missing folders")
		os.Mkdir(path, 0755)
	}
}
