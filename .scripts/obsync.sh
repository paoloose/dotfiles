#!/bin/bash

: """
Obsidian wrapper script that
- Stash local changes
- Pull changes from upstream
- Run obsidian
- Commit and push new changes

Replace your Obsidian Exec line manually in your obsidian.desktop

    seticon.sh list | grep -i obsidian
    micro /usr/share/applications/obsidian.desktop

    Exec=/path/to/obsync.sh [device_name] %U
"""

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

shift 1 || error_exit "No environment name provided. Run with obsync.sh [environment name]"

function cleanup {
    error_exit "It is no clear what happened. But I cannot say it was successful. Pretty much an error yeah. Script was aborted btw."
}

trap 'cleanup' ERR

cd $OBSIDIAN_DIR
git stash || error_exit "Failed to stash changes"
git pull --rebase origin main || error_exit "Failed to pull changes from upstream"
git stash pop || :
$OBSIDIAN_BIN $@ || error_exit "Obsidian just closed unexpectedly. Changes will be saved anyway" || :

git add . || error_exit "git add command failed"
git commit -m "latest notes for $environment" || error_exit "Nothing to commit"
git pull --rebase origin main || error_exit "Failed to pull changes before changing. Unable to push."
git push origin main || error_exit "Failed to push changes"

error_exit "Files pushed succesfully! This error is actualy a notice"
