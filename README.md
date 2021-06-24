# 마인크래프트 서버 간단하게 구축하기

간단하지만 환경 설정은 간단하지 않습니다.

### 환경

- JAVA
- Linux / macOS (Windows는 권장하지 않습니다.)

---

[![Build & Publish to Release](https://github.com/aroxu/server-script/actions/workflows/main.yml/badge.svg)](https://github.com/aroxu/server-script/actions/workflows/main.yml)

## 사용방법 (아래 방법중 하나를 선택하세요)

### - server (기본)

1. [Release 탭](https://github.com/monun/server-script/releases) 에서 자신의 환경에 맞는 파일을 다운로드
2. 실행권한 부여 `chmod +x ./server`
3. 실행 `./server` (현재 폴더에서 서버 실행됨)
4. [선택] 서버 시작시 생성된 ./server.conf.json 파일을 필요대로 수정

## server.conf.json의 server 설정 (서버로 사용할 jar파일)

1. URL (웹에서 파일을 다운로드하여 `server=~/.minecraft/server/` 폴더에 저장 후 서버 시작)
   - `server=https://papermc.io/api/v1/paper/1.16.5/latest/download`
2. 로컬 경로
   - `server=/user/monun/my.jar`
   - `server=$HOME/.jar`
   - `server=C:\\Users\monun\my.jar`
