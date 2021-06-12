# 마인크래프트 서버 간단하게 구축하기

간단하지만 환경은 간단하지 않습니다.
윈도우 유저분들은 WSL을 사용하세요.
---
환경
* JAVA
* LINUX (shell)

> ## 사용방법 (아래 방법중 하나를 선택하세요)
> ### - server.sh (기본)
> 1. .server/server.sh 파일을 다운로드 `wget https://raw.githubusercontent.com/monun/server-script/master/.server/server.sh`
> 2. 실행권한 부여 `chmod +x ./server.sh`
> 3. 실행 `./server.sh` (현재 폴더에서 서버 실행됨)
> 4. [선택] 서버 시작시 생성된 ./server.sh.conf 파일을 필요대로 수정
> ### - \<server>.sh (사전 설정 가능)
> 1. 원하는 스크립트 선택 (아래 방법 중 하나를 선택)
>   * 예) paper 스크립트 다운로드 `wget https://raw.githubusercontent.com/monun/server-script/master/paper.sh`
>   * 예) 프로젝트를 복제 `git clone https://github.com/monun/server-script.git`
> 2. [선택] 스크립트를 수정 (플러그인, 백업, 재시작 등)
> 3. 실행권한 부여 `chmod +x ./<script>.sh`
> 4. 실행 `./<script>.sh` (.\<script> 폴더에서 server.sh 스크립트를 이용한 서버가 실행됨)
> 5. [선택] 사전설정된 스크립트를 배포
