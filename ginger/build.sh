#!/bin/bash

gingervm="/home/ubuntu/.ginger/bin/gingervm"

usage() {
  echo "Usage: $0 -o <organization> -i <image> -s <server> -v <image_version>"
  exit 1
}

while getopts "o:i:s:v:" opt; do
  case $opt in
    o) organization=$OPTARG ;;
    i) image=$OPTARG ;;
    s) server=$OPTARG ;;
    v) image_version=$OPTARG ;;
    \?) usage ;;
  esac
done

if [ -z "$organization" ] || [ -z "$image" ] || [ -z "$server" || [ -z "$image_version" ]; then
  usage
fi

org_id=$($gingervm organization list | awk "/$organization/"' { print $1 }')
image_id=$($gingervm image list --org "${org_id}" | awk "/$image/"' { print $2 }')
server_id=$($gingervm server list --org "${org_id}" | awk "/$server/"' { print $2 }')
echo "Organization ID: ${org_id}"
echo "Image ID: ${image_id}"
echo "Server ID: ${server_id}"

echo "Creating the image version"
image_version_id=$(sudo -E $gingervm image version create --org "${org_id}" --image "${image_id}" --config image.yaml --name "${image_version}")

echo "Creating the server deployment"
sudo -E $gingervm server deployment create --org "${org_id}" --server "${server_id}" \
    --config deployment.yaml --version "${image_version_id}"

echo "Creating the data disk"
sudo -E $gingervm data-disk create --config data.yaml

echo "Delete the image version with the command below"
echo "gingervm image version delete --org ${org_id} --image ${image_id} --id ${image_version_id}"
