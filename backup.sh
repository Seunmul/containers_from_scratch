# cpu.cfs_period_us, cpu.cfs_quota_us, cpu.shares 파일에 CPU 제한 설정
# containers_from_scratch_cpu="/sys/fs/cgroup/cpu/containers_from_scratch"
# mkdir -m 0755 -p "$containers_from_scratch_cpu"
# echo "100000" > "$containers_from_scratch_cpu/cpu.cfs_period_us";
# echo  "-1" > "$containers_from_scratch_cpu/cpu.cfs_quota_us";
# echo "1024" > "$containers_from_scratch_cpu/cpu.shares";
# echo "1" > "$containers_from_scratch_cpu/notify_on_release"
# chmod 0700 > "$containers_from_scratch_cpu/notify_on_release"
# echo "$$" >"$containers_from_scratch_cpu/cgroup.procs"
