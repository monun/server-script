package config

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"monun/server-script/utils/logger"
	"os"
)

type Config struct {
	Server    string   `json:"server"`
	Debug     bool     `json:"debug"`
	DebugPort int      `json:"debug_port"`
	Backup    bool     `json:"backup"`
	Restart   bool     `json:"restart"`
	Memory    int      `json:"memory"`
	Plugins   []string `json:"plugins"`
	JarArgs   []string `json:"jarArgs"`
}

func LoadConfig() Config {
	var config Config
	currentPath, _ := os.Getwd()
	configPath := currentPath + "/server.conf.json"

	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		logger.Warn("'server.conf.json' file is missing! Creating...")
		generateConfig()
	}

	configData, loadFileErr := ioutil.ReadFile(configPath)
	if loadFileErr != nil {
		logger.Error(fmt.Sprintf("There was an error while reading 'server.conf.json': %s", loadFileErr))
	}

	json.Unmarshal([]byte(configData), &config)
	return config
}

func generateConfig() {
	serverConfFile, errGenConf := os.Create("server.conf.json")

	if errGenConf != nil {
		logger.Fatal(fmt.Sprintf("There was an error while generating server.conf.json: %s", errGenConf))
	}

	defer serverConfFile.Close()

	_, errWrtConf := serverConfFile.WriteString(`{
  "server": "https://papermc.io/api/v1/paper/1.16.5/latest/download",
  "debug": false,
  "debug_port": 5005,
  "backup": true,
  "restart": true,
  "memory": 4,
  "plugins": [
    "https://github.com/monun/kotlin-plugin/releases/latest/download/Kotlin-1.5.10.jar",
    "https://github.com/dmulloy2/ProtocolLib/releases/latest/download/ProtocolLib.jar"
  ],
  "jarArgs": [""],
}`)

	if errWrtConf != nil {
		logger.Fatal(fmt.Sprintf("There was an error while writing server.conf.json: %s", errWrtConf))
	}
	logger.Info("Successfully created server.conf.json")
}
