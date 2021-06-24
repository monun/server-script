mkdir -p build
GOOS=darwin GOARCH=amd64 go build -o build/server_darwin_x64
GOOS=linux GOARCH=amd64 go build -o build/server_linux_x64
GOOS=linux GOARCH=386 go build -o build/server_linux_x86
GOOS=windows GOARCH=amd64 go build -o build/server_windows_x64.exe
GOOS=windows GOARCH=386 go build -o build/server_windows_x86.exe
