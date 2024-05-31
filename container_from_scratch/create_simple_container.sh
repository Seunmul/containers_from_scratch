#!/bin/bash

# Step 1: 네임스페이스 선택 및 격리할 리소스 결정
# 이 예제에서는 PID, 네트워크, UTS 네임스페이스를 격리합니다.
UNSHARE_FLAGS="--pid --net --uts"

# Step 2: 성능 제어를 위한 cgroup 생성 및 구성
# 'mycgroup' 이름으로 CPU와 메모리 cgroup 생성
sudo cgcreate -g cpu,memory:/mycgroup

# CPU 제한 설정: CPU 코어 하나의 50% 사용량으로 제한
sudo cgset -r cpu.shares=512 mycgroup

# 메모리 제한 설정: 256MB
sudo cgset -r memory.limit_in_bytes=268435456 mycgroup

# Step 3: 네임스페이스를 사용하여 프로세스 격리
# 'unshare' 명령을 사용하여 격리된 새 쉘 시작
sudo unshare $UNSHARE_FLAGS /bin/bash <<EOF

# 독립된 호스트 이름 설정
hostname isolated-container

# 독립된 네트워크 설정
ifconfig lo 127.0.0.1 up

# Step 4: 격리 환경에서 성능 제어 리소스 그룹에 명시된 환경에서 프로세스 형성
# 'cgexec'를 사용하여 설정된 cgroup 내에서 bash 쉘 실행
sudo cgexec -g cpu,memory:mycgroup /bin/bash

# Step 5: 격리된 환경에서 작업 수행
# 여기서는 간단한 명령을 실행하겠습니다.
echo "Running in an isolated environment with limited resources..."
uptime

EOF

