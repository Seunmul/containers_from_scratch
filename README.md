# Container Playground

```bash
gcc -o escape_chroot escape_chroot.c -static
```

```bash
gcc -o cpu_test cpu_test.c -static
```

```bash
$ su ## root 권한으로 진행 su가 안되면 sudo 사용하기
$ cd /
$ mkdir /container_tmp
$ cd container_tmp
$ pwd
# /container_tmp

$ tree -L 1 .
container_tmp
├── create_container.sh
├── entrypoint.sh
├── main.go
├── myroot.tar

# 위와 같은 경로가 되게끔 이 되게끔 파일 복사 및 다운로드
# 이후 myroot.tar 압축ㅎ해제
tar -xvf myroot.tar

$ tree -L 1 .
.
├── create_container.sh
├── entrypoint.sh
├── main.go
├── myroot
└── myroot.tar

#이후 bash script 실행
$ create_container.sh
```

```bash
go run main.go run /bin/bash
```
