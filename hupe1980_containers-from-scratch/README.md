# Containers from Scratch in Go
This is a container build from scratch in a few lines of Go code. It uses namespaces and cgroups and mounts a tmpfs that's isolated from host filesystem. The project must be run in a Linux environment (GOOS=linux). You can use vagrant to spin up a virtual linux machine. It is based on the great talk from Liz Rice - [Containers From Scratch](https://www.youtube.com/watch?v=MHv6cWjvQjM&t=1316sc)

## Installation (linux)
- Run `make ubuntufs` to create a ubuntu filesystem (Docker required)
- Run `make run` to start the container

## Installation (non linux)
- Run `make ubuntufs` to create a ubuntu filesystem (Docker required)
- Run `vagrant up`
- Run `vagrant ssh`
- Change to the synced folder with `cd container`
- Run `make run` to start the container  

## How it works
- The program forks itself with `CLONE_NEWUTS`, `CLONE_NEWPID`, `CLONE_NEWNS` flags to get isolated hostname, processes and mounts
- The forked process creates a `cgroup` to limit pids to max 20
- It mounts the `./ubuntu_fs` directory as root filesystem using `chroot` to limit access to host machine's filesystem
- It mounts the `/mytemp` directory as tmpfs. Changes to this directory are not visible from the host.
- It mounts the proc directory (after `CLONE_NEWPID` namespace was already set) so that when you run `ps` in the container, only the processes running in it are displayed.
- It executes the supplied argument `/bin/bash` inside the isolated environment (=container)

## Testing
You can run a fork bomb `:(){ :|:& };:` in the container to test the cgroup limitation. WARNING! These examples may crash your computer if executed.
