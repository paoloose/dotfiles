#!/bin/bash

set -eE

OBSIDIAN_DIR="/home/paolo/Documents/ObsidianVault"
OBSIDIAN_BIN="obsidian"

function exists {
    bin=$1
}

function get_gui_alert_cmd {
    local cmd=''
    if command -v zenity &>/dev/null; then
        cmd="zenity --error --text "
    elif command -v kdialog &>/dev/null; then
        cmd="kdialog --error "
    elif command -v notify-send &>/dev/null; then
        cmd="notify-send Error "
    elif command -v gxmessage &>/dev/null; then
        cmd="gxmessage "
    elif command -v xmessage &>/dev/null; then
        cmd="xmessage "
    else
        cmd="echo"
    fi
    echo "$cmd"
}

error_cmd="$(get_gui_alert_cmd)"
environment="$1"

error_exit() {
    $error_cmd "$@"
    exit 1
}

shift 1

function cleanup {
    $alert_cmd "It is no clear what happened. But I cannot say it was successful. Pretty much an error yeah. Script was aborted."
}

trap 'cleanup' ERR

cd $OBSIDIAN_DIR
git stash || error_exit "Failed to stash changes"
git pull origin main || error_exit "Failed to pull changes from upstream"
git stash pop || error_exit "Failed to pop stash"
$OBSIDIAN_BIN $@ || error_exit "Failed to start obsidian"

git add .
git commit -m "latest notes for $environment"
git push origin main || error_exit "Failed to push changes"
