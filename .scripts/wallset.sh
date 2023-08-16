#!/bin/bash
set -e

# This tool sets wallpapers from https://wallhaven.cc
# Usage: wallset.sh <code> or wallset.sh <link>

cache=$HOME/.assets/wallpapers
valid_extensions="jpg png jpeg"

if [ ! -d "$cache" ]; then
    mkdir -p "$cache"
fi

user_input=$1
using_link=false

wget_flags=(
    --quiet
    --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:35.0) Gecko/20100101 Firefox/35.0"
)

function index_of_substr() {
    # $1 = str, $2 = substr
    local found=${1%%$2*}
    local index=${#found}

    if [ $index = ${#found} ]; then echo -1; else echo $index; fi
}

export PID=$$
trap "exit 1" SIGTERM SIGINT
function exit_err() {
    if [ -n "$1" ]; then echo $1 >&2; fi
    kill -s TERM $PID
}

# if you use other tool than feh
function set_wallpaper() {
    # $1 is a local img file
    feh --bg-max $1
}

# $1 is url, $2 is output file (if empty, the file name in the url will be used)
function download_img() {
    local url=$1
    local filename=$2

    local out="$cache/$filename"

    if [ -z $filename ]; then
        out="$cache/"$(basename $url)
    fi

    local is_valid=false

    for ext in $valid_extensions; do
        case $url in
            *".$ext")
                referer=$url
                status=$(wget "${wget_flags[@]}" --referer=$referer --server-response $url -O "$out" 2>&1 | awk '/^  HTTP/{print $2}')
                if [ "$status" != 200 ]; then
                    rm "$out"
                    exit_err "error from '$url': status: $status";
                fi
                is_valid=true
                echo $out
                return
            ;;
        esac
    done

    if [ is_valid = false ]; then
        exit_err "invalid file format, expected the following: $valid_extensions"
    fi
}

function main() {
    local imgcode=""
    local base_url=""

    case $user_input in
        "https://wallhaven.cc/w/"* | "http://wallhaven.cc/w/"*)
            # input is a fill link
            echo "using wallheaven"
            imgcode=${user_input##*"wallhaven.cc/w/"} # get all after prefix */w/
        ;;
        "http"*)
            set_wallpaper $(download_img $user_input)
            exit 0
        ;;
        *)
            # using a code like 8ojvek
            echo "using wallheaven"
            imgcode=$user_input
        ;;
    esac

    # If reached here, user want to download a wallpaper from https://wallhaven.cc/

    if [ ${#imgcode} != 6 ]; then
        exit_err "invalid wallhaven.cc image code: '$imgcode'!"
    fi

    base_url=https://w.wallhaven.cc/full/${imgcode:0:2}/

    local extension_found=""
    # extensions is unkown on the url, so we need to resolve it
    for ext in $valid_extensions; do
        # check if image is already download
        if [ -f "$cache/$imgcode.$ext" ]; then
            set_wallpaper "$cache/$imgcode.$ext"
            exit 0
        fi
        # check if image exists (without downloading it)
        if wget $wget_flags --spider "$base_url/wallhaven-$imgcode.$ext"; then
            extension_found=$ext
            echo "found extension: $extension_found"
            break
        fi
    done

    if [ -z $extension_found ]; then
        exit_err "could not found the image. try providing the full link"
    fi

    local url="$base_url/wallhaven-$imgcode.$extension_found"

    set_wallpaper $(download_img $url "$imgcode.$extension_found")
}

main
