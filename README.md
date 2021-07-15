# 마인크래프트 서버 간단하게 구축하기

윈도우 유저분들은 WSL혹은 mingw64를 통해 실행하세요.

#### mingw64
* git을 설치하면 `C:\Program Files\Git\mingw64` 경로에 자동으로 설치됩니다.
* 환경변수 PATH에 `C:\Program Files\Git\mingw64\bin` 을 추가하세요.
* [wget.exe](https://eternallybored.org/misc/wget/) 파일을 다운로드하여 mingw64 폴더에 넣어주세요.

### 환경
* JAVA
* LINUX (shell)
---
## 사용방법 (아래 방법중 하나를 선택하세요)
### - start.sh (기본)
1. .server/start.sh 파일을 다운로드 `wget https://raw.githubusercontent.com/monun/server-script/master/.server/start.sh`
2. 실행권한 부여 `chmod +x ./start.sh`
3. 실행 `./start.sh` (현재 폴더에서 서버 실행됨)
4. [선택] 서버 시작시 생성된 ./start.sh.conf 파일을 필요대로 수정
### - \<server>.sh (사전 설정 가능)
1. 원하는 스크립트 선택 (아래 방법 중 하나를 선택)
   * 예) paper 스크립트 다운로드 `wget https://raw.githubusercontent.com/monun/server-script/master/paper.sh`
   * 예) 프로젝트를 복제 `git clone https://github.com/monun/server-script.git`
2. [선택] 스크립트를 수정 (플러그인, 백업, 재시작 등)
3. 실행권한 부여 `chmod +x ./<script>.sh`
4. 실행 `./<script>.sh` (.\<script> 폴더에서 server.sh 스크립트를 이용한 서버가 실행됨)
5. [선택] 사전설정된 스크립트를 배포
## start.sh.conf의 server 설정 (서버로 사용할 jar파일)
1. URL (웹에서 파일을 다운로드하여 `~/.minecraft/server/` 폴더에 저장 후 서버 시작)
   * `server=https://papermc.io/api/v1/paper/1.7/latest/download`
2. 로컬 경로
   * `server=/user/monun/my.jar`
   * `server=$HOME/.jar`
   * `server=C:\\Users\monun\my.jar`
4. 현재 디렉토리에서 자동으로 찾기
   * `server=.`
## 문제해결
* 다운로드한 server jar이 인식이 안돼요
  * grep 에서 pearl 정규식을 사용 할 수 있어야 합니다. grep을 업데이트 해보세요(기준: grep 3.6)
## 다른 구현체들
Go언어로 제작된 서버 실행기: [aroxu](https://github.com/aroxu/server-script)
