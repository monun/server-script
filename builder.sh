mkdir -p build/server_darwin_x64
mkdir -p build/server_linux_x64
mkdir -p build/server_linux_x86
mkdir -p build/server_win_x64
mkdir -p build/server_win_x86
GOOS=darwin GOARCH=amd64 go build -o build/server_darwin_x64/server
GOOS=linux GOARCH=amd64 go build -o build/server_linux_x64/server
GOOS=linux GOARCH=386 go build -o build/server_linux_x86/server
GOOS=windows GOARCH=amd64 go build -o build/server_win_x64/server.exe
GOOS=windows GOARCH=386 go build -o build/server_win_x86/server.exe
