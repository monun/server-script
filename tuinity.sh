#!/bin/bash

server='https://ci.codemc.io/job/Spottedleaf/job/Tuinity/lastSuccessfulBuild/artifact/tuinity-paperclip.jar'
plugins=(
    'https://github.com/monun/kotlin-plugin/releases/latest/download/Kotlin-1.5.10.jar'
    'https://github.com/dmulloy2/ProtocolLib/releases/latest/download/ProtocolLib.jar'
)

script=$(basename "$0")
server_folder=".${script%.*}"
mkdir -p "$server_folder"
cd "$server_folder"

server_script="server.sh"
server_config="server.sh.conf"

if [ ! -f "$server_script" ]; then
  wget -qc -N 'https://raw.githubusercontent.com/monun/server-script/master/.server/server.sh'
fi

if [ ! -f "$server_config" ]; then
    cat << EOF > $server_config
server=$server
#server=
debug=false
debug_port=5005
backup=true
restart=true
memory=16
plugins=(
EOF
    for plugin in "${plugins[@]}"
    do
        echo "  \"$plugin\"" >> $server_config
    done
    echo ")" >> $server_config
fi

chmod +x ./$server_script
./$server_script