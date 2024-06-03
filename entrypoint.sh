echo "Running in an isolated environment with limited resources..."

# ls
echo "Setting up namespaces"
# hostname container
ip addr show

echo "Setting up cgroups\n"
# cgroup pids디렉토리 생성
containers_from_scratch_pids="/sys/fs/cgroup/pids/containers_from_scratch"
mkdir -m 0755 -p "$containers_from_scratch_pids"

# pids.max 파일에 최대 PID 수 제한 설정
echo "5" >"$containers_from_scratch_pids/pids.max"
chmod 0700 "$containers_from_scratch_pids/pids.max"

# notify_on_release 파일에 클린업 설정
echo "1" >"$containers_from_scratch_pids/notify_on_release"
chmod 0700 "$containers_from_scratch_pids/notify_on_release"

# add current process to the cgroup
echo "$$" >"$containers_from_scratch_pids/cgroup.procs"

ls -l "$containers_from_scratch_pids"
echo "Setting up cgroups done"
echo "pids.max: "
cat "$containers_from_scratch_pids/pids.max"

# Set up the container root
echo "initializing container"
mount --bind ./myroot ./new_root/
mkdir -p new_root/put_old
pivot_root new_root new_root/put_old
cd /
mount -t proc proc /proc
umount -l /put_old
rmdir /put_old

echo "executing chroot"
exec chroot . /bin/bash

# cat /etc/os-release
# kill -9 $$
# :(){ :|:& };: