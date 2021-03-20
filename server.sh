#!/bin/sh

server=paper
version=1.16.5
plugins=(
    'https://github.com/monun/kotlin-plugin/releases/latest/download/Kotlin-1.4.31.jar'
    'https://github.com/monun/auto-update/releases/latest/download/AutoUpdate.jar'
    'https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar'
)

script=$(basename "$0")
server_folder=".${script%.*}"
mkdir -p "$server_folder"

cd "$server_folder"

wget "https://raw.githubusercontent.com/monun/server-script/master/$server.sh"

config="./$server.conf"

if [ ! -f "$config" ]
then
    cat << EOF > $config
jar_url="https://papermc.io/api/v1/paper/$version/latest/download"
debug=false
debug_port=5005
backup=true
restart=true
memory=8
plugins=(
EOF
    for plugin in "${plugins[@]}"
    do
        echo "  \"$plugin\"" >> $config
    done
    echo ")" >> $config
fi

./$server.sh