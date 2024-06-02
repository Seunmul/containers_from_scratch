package main

import (
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"syscall"
)

func main() {
	switch os.Args[1] {
	case "run":
		run(os.Args[2:]...)
	case "child":
		child(os.Args[2:]...)
	default:
		log.Fatal("Unknown command. Use run <command_name>, like `run /bin/bash` or `run echo hello`")
	}
}

func run(command ...string) {
	log.Println("Executing", command, "from run")

	// sys_clone
	cmd := exec.Command("/proc/self/exe", append([]string{"child"}, command[0:]...)...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// Cloneflags is only available in Linux
	// CLONE_NEWUTS namespace isolates hostname
	// CLONE_NEWPID namespace isolates processes
	// CLONE_NEWNS namespace isolates mounts
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWPID | syscall.CLONE_NEWNS,
		Unshareflags: syscall.CLONE_NEWNS,
	}

	// Run child using namespaces. The command provided will be executed inside that.
	must(cmd.Run())
}

func child(command ...string) {
	log.Println("Executing", command, "from child")

	// Create cgroup
	cg()

	cmd := exec.Command(command[0], command[1:]...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	must(syscall.Sethostname([]byte("container")))

	// // Chroot to a directory
	// must(syscall.Chroot("./myroot"))
	// // Change directory after chroot
	// must(os.Chdir("/"))
	// // Mount /proc inside container so that `ps` command works
	// must(syscall.Mount("proc", "proc", "proc", 0, ""))
	
	//created by ghpark: pivotRoot
	pivotRoot("./myroot")

	// Mount a temporary filesystem
	if _, err := os.Stat("mytemp"); os.IsNotExist(err) {
		must(os.Mkdir("mytemp", os.ModePerm))
	}
	must(syscall.Mount("something", "mytemp", "tmpfs", 0, ""))

	// exec command
	must(cmd.Run())

	// Cleanup mount
	must(syscall.Unmount("proc", 0))
	must(syscall.Unmount("mytemp", 0))
}

func cg() {
	// cgroup location in Ubuntu
	cgroups := "/sys/fs/cgroup/"

	pids := filepath.Join(cgroups, "pids")
	containers_from_scratch := filepath.Join(pids, "containers_from_scratch")
	os.Mkdir(containers_from_scratch, 0755)
	// Limit to max 20 pids
	must(ioutil.WriteFile(filepath.Join(containers_from_scratch, "pids.max"), []byte("20"), 0700))
	// Cleanup cgroup when it is not being used
	must(ioutil.WriteFile(filepath.Join(containers_from_scratch, "notify_on_release"), []byte("1"), 0700))

	pid := strconv.Itoa(os.Getpid())
	// Apply this and any child process in this cgroup
	must(ioutil.WriteFile(filepath.Join(containers_from_scratch, "cgroup.procs"), []byte(pid), 0700))
}

//created by ghpark
func pivotRoot(src_root string){
	if _, err := os.Stat("./new_root"); os.IsNotExist(err) {
		must(os.Mkdir("./new_root", os.ModePerm))
	}
	// mount --bind /myroot /new_root
	must(syscall.Mount(src_root, "./new_root", "", syscall.MS_BIND, ""))

	// mkdir put_old
	must(os.MkdirAll("./new_root/put_old", 0700))

	// pivot root
	must(syscall.PivotRoot("./new_root", "./new_root/put_old"))
	must(os.Chdir("/"))

	// Mount /proc inside container so that `ps` command works
	must(syscall.Mount("proc", "proc", "proc", 0, ""))		

	//umount old root with lazy flag
	must(syscall.Unmount("/put_old", syscall.MNT_DETACH))

	// remove old root
	must(os.RemoveAll("/put_old"))
	
	// exec chroot . /bin/bash at new root -> to start new shell in new root
	must(exec.Command("chroot", ".", "/bin/bash").Run())
	must(os.Chdir("/"))
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}