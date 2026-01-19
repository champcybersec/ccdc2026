#!/bin/bash

# if we get an error, don't exit
set +e

DOCKER_IDS=$(docker ps -a -q)

if [ -z "$DOCKER_IDS" -o "$DOCKER_IDS" == " " ]; then
    echo "No docker containers exist"
    exit 0
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PATH=$PATH:$DIR/bins/

function inspect_ids() {
  for ID in $1
  do
    NAME=$(docker inspect --format="{{.Name}}" $ID)
    IMAGE=$(docker inspect --format="{{.Config.Image}}" $ID)
    PORTS=$(docker inspect $ID | jq '.[].NetworkSettings.Ports')
    STATUS=$(docker inspect --format="{{.State.Status}}" $ID)
    LOGPATH=$(docker inspect --format="{{.LogPath}}" $ID)
    IP=$(docker inspect --format="{{.NetworkSettings.IPAddress}}" $ID)
    CMD=$(docker inspect --format="{{.Config.Cmd}}" $ID)
    # get os from inspecting image
    OS=$(docker inspect --format="{{.Os}}" $IMAGE)
    echo "##################### Docker Container Info: $NAME #####################"
    echo "- ID: $ID"
    echo "- Status: $STATUS"
    echo "- Image: $IMAGE"
    echo "- Log Path: $LOGPATH"
    echo "- IP: $IP"
    echo "- OS: $OS"
    echo "- CMD:"
    echo "$CMD"
    echo "- Ports:"
    echo "$PORTS"
  done;
}

# don't run if we are sourcing this script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  inspect_ids "$DOCKER_IDS"
fi
