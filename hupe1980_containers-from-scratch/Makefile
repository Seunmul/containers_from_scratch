PROJECTNAME=$(shell basename "$(PWD)")

# Go related variables.
# Make is verbose in Linux. Make it silent.
MAKEFLAGS += --silent

.PHONY: run
run:
	@echo "Starting container..."
	@echo "[Container needs root privilege to create cgroups]"
	@sudo go run main.go run /bin/bash

.PHONY: ubuntufs
ubuntufs: 
	@echo "Creating Ubuntu Filesystem for container..."
	@docker run -d --rm --name ubuntu_fs ubuntu:20.04 sleep 1000
	@mkdir -p ./ubuntu_fs
	@docker cp ubuntu_fs:/ ./ubuntu_fs
	@docker stop ubuntu_fs

.PHONY: help
## help: Prints this help message
help: Makefile
	@echo
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo
