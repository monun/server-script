package main

import (
	"bufio"
	"fmt"
	"monun/server-script/config"
	"monun/server-script/utils"
	"monun/server-script/utils/file"
	"monun/server-script/utils/logger"
	"os"
	"os/signal"
	"strings"
	"time"

	"github.com/cavaliercoder/grab"
)

var serverFilePath string

type downloadResult struct {
	file  string
	dlerr error
}

type jarRuntime struct {
	serverFile string
	arguments  []string
}

var reader = bufio.NewReader(os.Stdin)
var configContent config.Config

func main() {
	for true {
		runner()
	}
}

func runner() {
	javaFlavor, javaVersion := utils.CheckJava()
	logger.Info(fmt.Sprintf("Checking Java..."))
	logger.Info(fmt.Sprintf("Detected %s %s", javaFlavor, javaVersion))

	configContent = config.LoadConfig()

	dlServerChannel := make(chan bool)
	dlPluginsChannel := make(chan bool)

	go downloadJar([]string{configContent.Server}, "server", dlServerChannel)
	go downloadJar(configContent.Plugins, "plugins", dlPluginsChannel)

	dlServerResult := <-dlServerChannel
	dlPluginsResult := <-dlPluginsChannel

	if dlServerResult && dlPluginsResult {
		logger.Info("Download job is done!")
	} else {
		logger.Info("Download job is failed!")
	}
	runtimeArgs := prepareRuntime(jarRuntime{}, configContent)
	utils.RunServer(append(append(runtimeArgs.arguments, "-jar"), runtimeArgs.serverFile))

	if configContent.Backup {
		ctrlCValid := true

		backupCanceled := false

		logger.Info("Server back-up will start in 5 seconds. Press Ctrl+C to cancel")
		fmt.Print("> ")
		ctrlCKeyEvent := make(chan os.Signal, 1)
		signal.Notify(ctrlCKeyEvent, os.Interrupt)

		go func() {
			for range ctrlCKeyEvent {
				if ctrlCValid {
					ctrlCValid = false
					backupCanceled = true
					fmt.Print("\n")
					logger.Warn("Server backup canceled.")
					return
				}
			}
		}()
		select {
		case <-time.After(5000 * time.Millisecond):
			if !backupCanceled {
				fmt.Print("\n")
				logger.Info("Starting Backup...")
				file.BackupServer()
				logger.Info("Backup Complete!")
			}
		}
		ctrlCValid = false
	}

	if configContent.Restart {
		ctrlCValid := true
		logger.Info("Server will restarts in 5 seconds. Press Ctrl+C to cancel")
		fmt.Print("> ")
		ctrlCKeyEvent := make(chan os.Signal, 1)
		signal.Notify(ctrlCKeyEvent, os.Interrupt)

		go func() {
			for range ctrlCKeyEvent {
				if ctrlCValid {
					ctrlCValid = false
					fmt.Print("\n")
					logger.Info("Exiting...")
					os.Exit(0)
				}
			}
		}()

		select {
		case <-time.After(5000 * time.Millisecond):
			ctrlCValid = false
			fmt.Print("\n")
			logger.Info("Starting Server...")
		}
		ctrlCValid = false
	} else {
		logger.Info("Exiting...")
		os.Exit(0)
	}
	if !utils.NormalStatusExit {
		logger.Fatal("There was an error while running server. If you didn't stop the process manually, Try to check 'server.conf.json'")
	}
}

func downloadJar(urls []string, downloadType string, complete chan<- bool) {
	var downloadDest string
	results := make(map[string]error)
	dlChannel := make(chan downloadResult)

	if downloadType == "server" {
		userHomeDir, err := os.UserHomeDir()
		if err != nil {
			logger.Fatal(fmt.Sprintf("Failed to get user's home dir: %s", err))
		}
		serverDirectory := userHomeDir + "/.minecraft/server/"

		logger.Info(fmt.Sprintf("Checking %s directory...", downloadType))
		file.CheckFolderExist(serverDirectory)
		downloadDest = serverDirectory

	} else if downloadType == "plugins" {
		currentPath, _ := os.Getwd()
		pluginDirectory := currentPath + "/plugins/"

		logger.Info(fmt.Sprintf("Checking %s directory...", downloadType))
		file.CheckFolderExist(pluginDirectory)
		downloadDest = pluginDirectory

	} else {
		logger.Fatal("Wrong download type!")
	}

	logger.Info(fmt.Sprintf("Preparing parallel download for %s...", downloadType))
	for _, url := range urls {
		go downloadFile(downloadType, downloadDest, url, dlChannel)
	}

	for i := 0; i < len(urls); i++ {
		downloadResult := <-dlChannel
		results[downloadResult.file] = downloadResult.dlerr
	}

	for downloadedFile, downloadError := range results {
		if downloadError != nil {
			logger.Error(fmt.Sprintf("There was an error while downloading %s: %s", downloadedFile, downloadError))
		}
	}
	logger.Info(fmt.Sprintf("Downloaded all %s files!", downloadType))
	complete <- true
	return
}

func downloadFile(downloadType, downloadDir, url string, err chan<- downloadResult) {
	if downloadType == "server" && !utils.IsValidUrl(url) {
		err <- downloadResult{file: url, dlerr: nil}
		return
	}

	client := grab.NewClient()
	req, _ := grab.NewRequest(downloadDir, url)
	resp := client.Do(req)

	t := time.NewTicker(time.Second)
	defer t.Stop()
Loop:
	for {
		select {
		case <-t.C:
			etaTime := time.Until(resp.ETA()).Round(time.Second).String()

			if strings.Contains(etaTime, "-") {
				etaTime = "Calculating..."
			}

			downloadSpeed := file.ByteCounter(int64(resp.BytesPerSecond()))
			currentDownloaded := file.ByteCounter(resp.BytesComplete())
			totalDownloaded := file.ByteCounter(resp.Size)

			jarPath := strings.Split(resp.Filename, "/")
			logger.Info(fmt.Sprintf("[%s] Downloaded %s of %s | ETA: %s | Download Speed: %s/s", jarPath[len(jarPath)-1], currentDownloaded,
				totalDownloaded,
				etaTime,
				downloadSpeed))

			// eta.SetText(fmt.Sprintf("남은 시간: %s | 다운로드 현황: %s/%s | 전송 속도: %s/s", etaTime, currentDownloaded, totalDownloaded, downloadSpeed))
		case <-resp.Done:
			break Loop
		}
	}

	if dlErr := resp.Err(); dlErr != nil {
		logger.Error(fmt.Sprintf("Download failed: %s\n", dlErr))
		err <- downloadResult{file: resp.Filename, dlerr: dlErr}
	}

	if downloadType == "server" {
		serverFilePath = resp.Filename
	}
	jarPath := strings.Split(resp.Filename, "/")

	logger.Info(fmt.Sprintf("[%s] Download complete", jarPath[len(jarPath)-1]))
	err <- downloadResult{file: resp.Filename, dlerr: nil}
	return
}

func prepareRuntime(runtime jarRuntime, config config.Config) jarRuntime {
	if !utils.IsValidUrl(config.Server) {
		runtime = jarRuntime{serverFile: config.Server}
	} else {
		runtime = jarRuntime{serverFile: serverFilePath}
	}

	for _, option := range []string{
		fmt.Sprintf("-Xmx%dG", config.Memory),
		fmt.Sprintf("-Xms%dG", config.Memory),
		"-XX:+ParallelRefProcEnabled",
		"-XX:MaxGCPauseMillis=200",
		"-XX:+UnlockExperimentalVMOptions",
		"-XX:+DisableExplicitGC",
		"-XX:+AlwaysPreTouch",
		"-XX:G1HeapWastePercent=5",
		"-XX:G1MixedGCCountTarget=4",
		"-XX:G1MixedGCLiveThresholdPercent=90",
		"-XX:G1RSetUpdatingPauseTimePercent=5",
		"-XX:SurvivorRatio=32",
		"-XX:+PerfDisableSharedMem",
		"-XX:MaxTenuringThreshold=1",
		"-Dusing.aikars.flags=https://mcflags.emc.gs",
		"-Daikars.new.flags=true",
		"-Dcom.mojang.eula.agree=true",
	} {
		runtime.arguments = append(runtime.arguments, option)
	}
	for _, option := range utils.SelectOptionByMemory(config.Memory) {
		runtime.arguments = append(runtime.arguments, option)
	}

	if config.Debug {
		debugOption := "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address="
		_, javaVersion := utils.CheckJava()
		if utils.VersionOrdinal("1.8") < utils.VersionOrdinal(javaVersion) {
			debugOption += fmt.Sprintf("*:%d", config.DebugPort)
		} else {
			debugOption += fmt.Sprintf("%d", config.DebugPort)
		}
		runtime.arguments = append(runtime.arguments, debugOption)
	}

	return runtime
}
