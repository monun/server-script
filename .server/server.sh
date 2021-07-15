#!/bin/bash

download() {
  wget -c --content-disposition -P "$2" -N "$1" 2>&1 | grep -Po '([A-Z]:)?[\/\.\-\w]+\.jar' | tail -1
}

# check java (https://stackoverflow.com/questions/7334754/correct-way-to-check-java-version-from-bash-script)
if type -p java; then
    echo "Found java executable in PATH"
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo "Found java executable in JAVA_HOME"
    _java="$JAVA_HOME/bin/java"
else
    echo "Not found java"
    exit
fi

script=$(basename "$0")
script_config="./$script.conf"

if [ ! -f "$script_config" ]; then
  cat << EOT > $script_config
debug=false
debug_port=5005
backup=true
restart=true
memory=16
server=https://papermc.io/api/v1/paper/1.17/latest/download
plugins=(

)
EOT
fi

source "$script_config"

# Print configurations
echo "server = $server"
echo "debug = $debug"
echo "backup = $backup"
echo "restart = $restart"
echo "memory = ${memory}G"

mkdir -p "./plugins"


if [ "$server" = "." ]; then
  jar=$(ls -dt ./*.jar | head -1)
elif [ -f "$server" ]; then
  jar=$server
else
  url_regex='^(https?):\/\/([a-zA-Z])+(\.([a-zA-Z]+))+(:[\d]*)?(\/.*)*?$'
  if [[ $server =~ $url_regex ]]; then
    jar_folder="$HOME/.minecraft/server/"
    mkdir -p "$jar_folder"
    jar=$(download "$server" "$jar_folder")
  else
    echo "Not found server jar"
    exit
  fi
fi

echo "jar = $jar"

# Download plugins
for i in "${plugins[@]}"; do
  download_result=$(download "$i" "./plugins")
  echo "$download_result <- $i"
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

if [[ $memory -lt 12 ]]
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

if [[ $debug = true ]]; then
  port_arguments="$debug_port"

  java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  java_version_9="9"

  if [ "$(printf '%s\n' "$java_version" "$java_version_9" | sort -V | head -n1)" = "$java_version_9" ]; then
    echo "DEBUG MODE: JDK9+"
    port_arguments="*:$port_arguments"
  else
    echo "DEBUG MODE: JDK8"
  fi

  jvm_arguments+=("-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$port_arguments")
fi

jvm_arguments+=(
  "-jar"
  "$jar"
  "nogui"
)

while :
do
  "$_java" "${jvm_arguments[@]}"

  if [[ $backup = true ]]; then
    read -r -t 5 -p "Press Enter to start the backup immediately or Ctrl+C to cancel `echo $'\n> '`"
    echo 'Start the backup.'
    backup_file_name=$(date +"%y%m%d-%H%M%S")
    mkdir -p '.backup'
    tar --exclude='./.backup' --exclude='*.gz' --exclude='./cache' -zcf ".backup/$backup_file_name.tar.gz" .
    echo 'The backup is complete.'
  fi

  if [[ $restart = "false" ]]; then
    break
  fi

  read -r -t 5 -p "The server restarts. Press Enter to start immediately or Ctrl+C to cancel `echo $'\n> '`"
  echo "The server will be restarted."
done
