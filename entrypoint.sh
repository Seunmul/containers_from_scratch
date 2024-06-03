echo "Running in an isolated environment with limited resources..."

# ls
echo "Setting up namespaces"
hostname container
# ip addr show

# Setting up cgroups
echo "Setting up cgroups\n"
## cgroup pids: create new cgroup below pids hierarchy
containers_from_scratch_pids="/sys/fs/cgroup/pids/containers_from_scratch"
mkdir -m 0755 -p "$containers_from_scratch_pids"

## pids.max: set the maximum number of processes
echo "5" >"$containers_from_scratch_pids/pids.max"
chmod 0700 "$containers_from_scratch_pids/pids.max"

## notify_on_release: Cleanup the cgroup when it is empty
echo "1" >"$containers_from_scratch_pids/notify_on_release"
chmod 0700 "$containers_from_scratch_pids/notify_on_release"

## add current process to the cgroup
echo "$$" >"$containers_from_scratch_pids/cgroup.procs"

ls -l "$containers_from_scratch_pids"
echo "Setting up cgroups done"
echo "pids.max: "
cat "$containers_from_scratch_pids/pids.max"

# Set up the container root
echo "initializing container"

mkdir -p ./new_root               ## create a new root directory
mount --bind ./myroot ./new_root/ ## bind the myroot directory to the new root directory
mkdir -p ./new_root/put_old       ## create a new directory for the old root

pivot_root ./new_root ./new_root/put_old ## pivot_root to the new root directory

cd /                     ## change the directory to the root directory
mount -t proc proc /proc ## mount the proc filesystem
umount -l /put_old       ## unmount the old root directory
rmdir /put_old           ## remove the old root directory

echo "executing chroot"
exec chroot . /bin/bash ## execute the bash shell in the new root directory

# cat /etc/os-release
# kill -9 $$
# :(){ :|:& };:
