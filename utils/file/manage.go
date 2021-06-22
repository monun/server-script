package file

import (
	"monun/server-script/utils/logger"
	"os"
)

func CheckFolderExist(path string) {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		// path/to/whatever does not exist
		os.Mkdir(path, 0755)
		logger.Warn("Generating missing folders")
	}
}
