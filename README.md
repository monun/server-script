# 마인크래프트 서버 간단하게 구축하기

간단하지만 환경 설정은 간단하지 않습니다.

### 환경

- JAVA
- Linux / macOS (Windows는 권장하지 않습니다.)

---

[![Build & Publish to Release](https://github.com/aroxu/server-script/actions/workflows/main.yml/badge.svg)](https://github.com/aroxu/server-script/actions/workflows/main.yml)

## 사용방법 (아래 방법중 하나를 선택하세요)

#### 사전 고지 사항: Windows 빌드는 Ctrl + C 이벤트가 간헐적으로 작동되지 않을 수 있습니다. 이는 다른 방법으로 변경될 예정입니다. 자세한 내용은 [TODO.md](TODO.md)를 참고하세요.

### - server (기본 실행 방법)

1. [Release 탭](https://github.com/aroxu/server-script/releases) 에서 자신의 환경에 맞는 파일을 다운로드. ex) `wget https://github.com/aroxu/server-script/releases/latest/download/server_linux_x64.zip`
2. 압축 해재. ex) `unzip server_linux_x64.zip`
3. 실행권한 부여. ex) `chmod +x ./server` (윈도우는 제외)
4. 실행 `./server` (현재 폴더에서 서버 실행됨)
5. [선택] 서버 시작시 생성된 ./server.conf.json 파일을 필요대로 수정

### - server (스크립트 수정 후 커스텀)

1. 이 레포를 복제합니다. `git clone https://github.com/aroxu/server-script`
2. 스크립트를 수정합니다.
3. 실행(`go run main.go`) (빌드를 하고 싶다면 `go build`를 입력하세요.)

## server.conf.json의 server 설정 (서버로 사용할 jar파일)

1. URL (웹에서 파일을 다운로드하여 `server=~/.minecraft/server/` 폴더에 저장 후 서버 시작)
   - `server=https://papermc.io/api/v1/paper/1.16.5/latest/download`
2. 로컬 경로
   - `server=/user/monun/my.jar`
   - `server=$HOME/.jar`
   - `server=C:\\Users\monun\my.jar`
