#!/bin/bash

set +e

container_list=$(docker ps -a -q)

if [[ -z "$container_list" || "$container_list" == " " ]]; then
    echo "No docker containers exist"
    exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$PATH:$script_dir/bins/"

inspect_ids() {
    local ids="$1"
    local id name image ports status logpath ip cmd os

    for id in $ids; do
        name=$(docker inspect --format="{{.Name}}" "$id")
        image=$(docker inspect --format="{{.Config.Image}}" "$id")
        ports=$(docker inspect "$id" | jq '.[].NetworkSettings.Ports')
        status=$(docker inspect --format="{{.State.Status}}" "$id")
        logpath=$(docker inspect --format="{{.LogPath}}" "$id")
        ip=$(docker inspect --format="{{.NetworkSettings.IPAddress}}" "$id")
        cmd=$(docker inspect --format="{{.Config.Cmd}}" "$id")
        os=$(docker inspect --format="{{.Os}}" "$image")

        echo "======== Docker Container Info: $name ========"
        echo "- ID: $id"
        echo "- Status: $status"
        echo "- Image: $image"
        echo "- Log Path: $logpath"
        echo "- IP: $ip"
        echo "- OS: $os"
        echo "- CMD:"
        echo "$cmd"
        echo "- Ports:"
        echo "$ports"
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    inspect_ids "$container_list"
fi
