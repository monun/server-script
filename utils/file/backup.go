package file

import (
	"archive/zip"
	"fmt"
	"io"
	"io/ioutil"
	"monun/server-script/utils/logger"
	"os"
	"path/filepath"
	"time"
)

type zipType struct {
	writer *zip.Writer
}

func BackupServer() {
	currentPath, _ := os.Getwd()
	backupDirectory := currentPath + "/.backup/"
	logger.Info(fmt.Sprintf("Checking %s directory...", "backup"))
	CheckFolderExist(backupDirectory)

	dt := time.Now()

	file, _ := os.Create(backupDirectory + dt.Format("20060102-150405") + ".zip")
	zipDir(file, currentPath)
}

func zipDir(saveFile *os.File, savePath string) error {
	zipWriter := zip.NewWriter(saveFile)
	defer zipWriter.Close()
	z := zipType{zipWriter}
	return z.dir(savePath, "")
}

func (z zipType) dir(dirPath string, zipPath string) error {
	files, err := ioutil.ReadDir(dirPath)
	if err != nil {
		return err
	}
	for _, file := range files {
		fullPath := dirPath + string(filepath.Separator) + file.Name()
		if file.IsDir() && file.Name() != ".backup" && file.Name() != ".cache" {
			if err != nil {
				return err
			}
			z.dir(fullPath, zipPath+file.Name()+string(filepath.Separator))
		} else {
			if err := z.file(file, fullPath, zipPath); err != nil {
				return err
			}
		}
	}
	return nil
}

func (z zipType) file(file os.FileInfo, filePath string, zipPath string) error {
	header, _ := zip.FileInfoHeader(file)
	header.Name = zipPath + header.Name

	w, err := z.writer.CreateHeader(header)
	if err != nil {
		return err
	}
	f, err := os.Open(filePath)
	if err != nil {
		return err
	}
	defer f.Close()
	io.Copy(w, f)

	return nil
}
