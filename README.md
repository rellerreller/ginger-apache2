# Introduction

This repository contains a Ginger OS configuration files for running an Apache2 web server. This is an example configuration based upon Ubuntu. The configuration files copy files as they are installed on an Ubuntu system. If running on a different operating system then check the file paths.

# Setup a Dev Environment

Follow the instructions for creating a development environment. The instructions can be found at https://www.gingercybersecurity.com/setup-dev.html.

# Running Locally on QEMU

This section will guide you through the process of building a Ginger VM with Apache2 installed. The guide assumes the host instance is Ubuntu and the development environment has already been setup. See the previous for instructions on how to setup a dev environment.

## Install Apache2

The Ginger OS configuration files copy files from the host system. This includes the apache2 binary and its modules.

```
sudo apt install apache2
# Stop and disable the Apache2 service since the host does not want it running
sudo systemctl stop apache2
sudo systemctl disable apache2
```

The modules directory includes an unnecessary, non-binary file in the modules directory. The file must be deleted before building the Ginger OS disk images or else an error will occur stating a file is not an executable file. Run the command below to remove the file.

```
sudo rm /usr/lib/apache2/modules/httpd.exp
```

## Configure QEMU

Run a configuration script that will establish a networking environment for the new virtual machine. The networking script will create a bridged network connection that uses Network Address Translation (NAT) to communicate via the Internet. The script is found in the hello-ginger-rust repo.

```
git clone https://github.com/rellerreller/hello-ginger-rust
cd hello-ginger-rust/ginger/
ip addr
# Get the network interface name that connects to the Internet.
# Edit setup.sh to set eth_internet to the network interface that connects to the Internet.
vim setup.sh
sudo bash -e setup.sh
```

## Build the Disk Images

### Clone the Repository
Clone the ginger-apache2 repository and create a target directory within the repository directory to store the disk images. Execute the code below.

```
git clone https://github.com/rellerreller/ginger-apache2
cd ginger-apache2
mkdir target
```

### Configure Networking

The init.yaml file specifies the networking details for the virtual machine. A static networking configuration can be used. Modify the networking section in init.yaml to use the networking details below. **The DNS entry should be modified to match your environment.**

```
networking:
  source: config
  ipv4:
    ip: 192.168.42.100
    netmask: 255.255.255.0
    broadcast: 192.168.42.255
    gateway: 192.168.42.1
    dns:
    - 10.0.0.2
```

### Build

Change into the ginger directory and build the disk images. If the disk image files did not previously exist then they will be created and owned by root. After creating the disk images then change the owner and group for the files.

```
# You must login and have an active session for the build script to run.
gingervm login
# Only create a new image if one has not been created. This should only be run once.
gingervm image create --org "Your Org ID" --name "apache2"
# Only create a new server if one has not been created. This should only be run once.
gingervm server create --org "Your Org ID" --name "apache2"
# Change the organization to match your organization's name. The image and server objects must be created prior to running the build script. If the names are different then change them accordingly.
bash -ex build.sh -o "Your Organization" -i "apache2" -s "apache2" -v "2.4.58"
# Change the ownership of the disk image files if the build script creates the new disk image files.
cd ../target
sudo chown ubuntu:ubuntu disk*
# Go back into the ginger directory for the next step
cd ../ginger
```

## Run the Virtual Machine

The final step is to run the virtual machine. From within the ginger directory run the command below. This will create a new Ginger OS virtual machine that runs the Apache2 web server.

```
bash launch.sh
# curl http://192.168.42.100/
```
