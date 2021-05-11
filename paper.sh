#!/bin/bash

download() {
  wget -c --content-disposition -P "$2" -N "$1" 2>&1 | tail -2 | head -1
}

script=$(basename "$0")
script_config="./$script.conf"

if [ ! -f "$script_config" ]
then
    cat << EOT > $script_config
jar_url="https://papermc.io/api/v1/paper/1.16.5/latest/download"
debug=false
debug_port=5005
backup=true
restart=true
memory=8
plugins=(
    'https://github.com/monun/kotlin-plugin/releases/latest/download/Kotlin-1.4.31.jar'
    'https://github.com/monun/auto-update/releases/latest/download/AutoUpdate.jar'
    'https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar'
)
EOT
fi

source "$script_config"

# Print configurations
echo "debug = $debug"
echo "backup = $backup"
echo "restart = $restart"
echo "memory = ${memory}G"

jar_folder="$HOME/.minecraft/server/paper"

mkdir -p "./plugins"
mkdir -p "$jar_folder"

# Download jar
download "$jar_url" "$jar_folder"
jar=$(ls -d $HOME/.minecraft/server/paper/*.jar -t | head -1)

# Download plugins
for i in "${plugins[@]}"
do
  download "$i" "./plugins"
done

jvm_arguments=(
  "-Xmx${memory}G"
  "-Xms${memory}G"
  "-XX:+ParallelRefProcEnabled"
  "-XX:MaxGCPauseMillis=200"
  "-XX:+UnlockExperimentalVMOptions"
  "-XX:+DisableExplicitGC"
  "-XX:+AlwaysPreTouch"
  "-XX:G1HeapWastePercent=5"
  "-XX:G1MixedGCCountTarget=4"
  "-XX:G1MixedGCLiveThresholdPercent=90"
  "-XX:G1RSetUpdatingPauseTimePercent=5"
  "-XX:SurvivorRatio=32"
  "-XX:+PerfDisableSharedMem"
  "-XX:MaxTenuringThreshold=1"
  "-Dusing.aikars.flags=https://mcflags.emc.gs"
  "-Daikars.new.flags=true"
  "-Dcom.mojang.eula.agree=true"
)

if (($memory < 12))
then
  echo "Use Aikar's standard memory options"
  jvm_arguments+=(
    "-XX:G1NewSizePercent=30"
    "-XX:G1MaxNewSizePercent=40"
    "-XX:G1HeapRegionSize=8M"
    "-XX:G1ReservePercent=20"
    "-XX:InitiatingHeapOccupancyPercent=15"
 )
else
  echo "Use Aikar's Advanced memory options"
  jvm_arguments+=(
    "-XX:G1NewSizePercent=40"
    "-XX:G1MaxNewSizePercent=50"
    "-XX:G1HeapRegionSize=16M"
    "-XX:G1ReservePercent=15"
    "-XX:InitiatingHeapOccupancyPercent=20"
  )
fi

if ($debug)
then
  jvm_arguments+=("-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:$debug_port")
fi

jvm_arguments+=(
  "-jar"
  "$jar"
  "--nogui"
)

while :
do
  java "${jvm_arguments[@]}"

  if ($backup)
  then
    read -r -t 5 -p "Press Enter to start the backup immediately or Ctrl+C to cancel `echo $'\n> '`"
    echo 'Start the backup.'
    backup_file_name=$(date +"%y%m%d-%H%M%S")
    mkdir -p '.backup'
    tar --exclude='./.backup' --exclude='*.gz' --exclude='./cache' -zcf ".backup/$backup_file_name.tar.gz" .
    echo 'The backup is complete.'
  fi

  if (! ($restart))
  then
    break
  fi

  read -r -t 5 -p "The server restarts. Press Enter to start immediately or Ctrl+C to cancel `echo $'\n> '`"
  
  echo "The server will be restarted."
done