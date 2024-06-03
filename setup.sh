#!/bin/bash
mkdir -m 0755 -p "/container_tmp"
cp ./create_container.sh /container_tmp/
cp ./setup_container.sh /container_tmp/
cp ./main.go /container_tmp/
## download the myroot
if [ ! -f ./myroot.tar ]; then
    wget https://github.com/Seunmul/containers_from_scratch/releases/download/1.1.0/myroot.tar
    sudo tar -xvf ./myroot.tar -C /container_tmp/
fi

ls /container_tmp/
echo "Finished setting up the container environment."
