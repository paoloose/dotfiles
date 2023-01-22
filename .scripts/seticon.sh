#!/bin/bash

# TODO:
# [X] - add --no-preview option
# [X] - add --help option
# [X] - add 'list' command to list all the .desktop files in the system
# [X] add a note about using sudo when needed
# [X] fix path concatenation '/'
# [X] Warning when overriding an existing icon
# [X] Log information

bin_name="seticon.sh"

# 🖼 Icons installer for Linux desktop applications
# Dependencies: convert (from ImageMagick), xdg-open (optional)

# References:
# https://wiki.archlinux.org/title/desktop_entries
# https://specifications.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html
# https://specifications.freedesktop.org/desktop-entry-spec/latest/index.html#introduction

main() {
    # This tool uses "convert" from ImageMagick
    which convert > /dev/null 2>&1
    if [ $? != 0 ]; then
        echo "error: this script requires 'convert' (from ImageMagick) to work"
        exit -1
    fi

    # Variables for the installation
    local desktop_file  # Path to the .desktop file
                        # (is optional when path_to_icons is provided)
    local icon_file     # Path to the .png icon
    local icon_name     # Icons should have a name defined in the .desktop file
    local path_to_icons # Path to the icons directory (usually /usr/share/icons)
                        # Is resolved to ../icons/hicolor

    local app_command          # (set or unset)
    local show_preview=true    # Show preview of the icon (only in 'set' mode)
    local overwrite_icons=false # Overwrite icons when (only in 'set' mode)

    # Get the input from the user and validate it
    get_input $@

    # We must have the $path_to_icons and $icon_name variables set
    # so if was not provided by the user, we need to find them

    # If the user didn't provide the icons directory, we try to find it
    # based on the .desktop file path
    if [ ! "$path_to_icons" ]; then
        find_path_to_icons
    fi

    # If the user didn't provide the icon name, we try to find it
    # based on the .desktop file content
    if [ ! "$icon_name" ]; then
        # If '$icon_name' isn't set, is because user provided the .desktop file
        # (see usage)

        # We try to use the "Icon" property defined in the .desktop file
        # otherwise, we use the name of the .desktop file

        local prev_icon_name
        prev_icon_name="$(cat "$desktop_file" | grep Icon)" # icon line
        prev_icon_name="${prev_icon_name##*=}" # Icon= value

        # Remove all the Icon definition from the .desktop file
        sed -i '/^Icon=/d' "$desktop_file" # remove Icon line

        if [ "$prev_icon_name" ]; then
            icon_name="$prev_icon_name"
        else
            icon_name="$(basename "$desktop_file")"
            icon_name="${icon_name%.*}" # remove extension
        fi
        # Redefine the icon name in the .desktop file
        echo "Icon=$icon_name" >> $desktop_file
    fi

    # All variables are set, now we can proceed with the set/unset

    # Find all the available resolutions in the /icons dir
    # They have the format .../icons/<num>x<num>
    local icon_resolutions="$(ls $path_to_icons | grep "^[0-9]*x[0-9]*$")"

    if [ ! "$icon_resolutions" ]; then
        exit_error "no icon directories found in '$path_to_icons'"
    fi

    # Print information about the installation
    echo
    if [ "$desktop_file" ]; then echo "Desktop file: '$desktop_file'"; fi
    if [ "$icon_file" ]; then echo "Icon file: '$icon_file'"; fi
    if [ "$icon_name" ]; then echo "Icon name: '$icon_name'"; fi
    if [ "$path_to_icons" ]; then echo "Icons directory: '$path_to_icons'"; fi
    echo

    # Proceed according to the app_command

    if [ "$app_command" == "set" ]; then
        # Preview the icon if '--no-preview' flag is not set
        # Check if `xdg-open` can be used to preview the image
        if $show_preview && ( which xdg-open > /dev/null 2>&1 ); then
            # If can, preview the image, then continue
            echo "Showing a preview for your new icon '$icon_file' ✨"
            echo "Close the preview to continue, otherwise press Ctrl+C"
            echo
            xdg-open "$icon_file" > /dev/null 2>&1
        fi

        # Now create the icons
        for res in $icon_resolutions; do
            local icon_path="$path_to_icons/$res/apps"
            if [ ! -d "$icon_path" ]; then exit_error "'$icon_path' doesn't exist"; fi

            if [ -f "$icon_path/$icon_name.png" ] && ! $overwrite_icons; then
                echo "Error at $icon_path/$icon_name.png"
                exit_error "already existing icons were detected, use '--overwrite'"
            fi

            # Create the icon
            echo -n "Icon $res/apps/$icon_name.png: "
            local convert_output
            convert_output=$(convert "$icon_file" -resize "$res" "$icon_path/$icon_name.png" 2>&1)

            if [ $? == 0 ]; then echo "done ✨";
            else echo; exit_error "$convert_output"; fi
        done
    elif [ "$app_command" == "unset" ]; then
        for res in $icon_resolutions; do
            local icon_to_remove="$path_to_icons/$res/apps/$icon_name.png"
            echo -n "Icon $res/apps/$icon_name.png: "
            local remove_output
            remove_output=$(rm -f "$icon_to_remove" 2>&1)

            if [ $? == 0 ]; then echo "removed ✨";
            else echo "$remove_output"; fi
        done
    fi

    echo $'\nUpdating icons cache...'
    gtk-update-icon-cache -f -t "$path_to_icons"
}

function get_input() {
    # Parse flags with `getopt`

    args=$(getopt -a -n $bin_name --options n,h,o --long no-preview,help,overwrite -- $@)
    if [ $? != 0 ]; then exit_bad_usage "bad arguments"; fi
    eval set -- "$args"

    while true; do
        case "$1" in
            -n|--no-preview) show_preview=false; shift 1;;
            -o|--overwrite) overwrite_icons=true; shift 1;;
            -h|--help)
                echo
                echo " 🖼️  $bin_name - Icons installer for Linux desktop applications"
                usage
                exit 0;;
            --) shift 1; break;;
        esac
    done

    app_command="$1"
    if [ ! "$app_command" ]; then exit_bad_usage "no command provided"; fi
    if [[ $app_command != "set" && $app_command != "unset" && $app_command != "list" ]]; then
        exit_bad_usage "unknown command '$app_command'"
    fi
    shift 1 # remove app_command from arguments
    # Now "$1" is the first argument, "$2" is the second, etc

    if [ "$app_command" == "list" ]; then
        if [ "$1" ]; then
            exit_bad_usage "'list' command doesn't receive arguments"
        fi
        list_applications_in_system
        exit 0
    fi

    if [ ! "$1" ]; then exit_bad_usage "$app_command: no arguments provided"; fi

    # Get and validate first argument
    # (it can be a .desktop file or a path to the icons directory)
    local arg1_basename="$(basename $1)"

    if [ "${arg1_basename: -8}" == ".desktop" ]; then
        desktop_file="$1"
        if [ ! -f "$desktop_file" ]; then
            exit_invalid "desktop file '$desktop_file' not found"
        fi
    elif [ ! "${arg1_basename##*"."*}" ]; then
        # unknown file type
        exit_bad_usage "bad file '$1' (expected .desktop or 'icons' directory)"
    else
        path_to_icons="$1"
        if [ ! -d "$path_to_icons" ]; then
            exit_invalid "icons directory '$path_to_icons' not found"
        fi
    fi

    # At this point, only one of '$desktop_file' or '$path_to_icons' is set
    # Now the rest of the arguments depend on the app_command

    if [ "$app_command" == "set" ]; then
        if [ "$desktop_file" ] && [ "$3" ]; then
            exit_bad_usage "set: third argument not expected"
        fi
        if [ "$path_to_icons" ] && [ "$4" ]; then
            exit_bad_usage "set: fourth argument not expected"
        fi
        if [ ! "$2" ]; then exit_bad_usage "no png icon provided"; fi

        # Validate second argument ($2) <icon.png>
        icon_file="$2"
        if [ "${icon_file: -4}" != ".png" ]; then
            exit_invalid "file '$icon_file' must have image/png type"
        elif [ ! -f "$icon_file" ]; then
            exit_invalid "file '$icon_file' not found"
        fi

        # Validate third argument ($3) <icon_name> (if provided)
        # <icon_name> is mandatory only when /path/to/icons is defined
        if [ "$path_to_icons" ]; then
            if [ ! "$3" ]; then exit_bad_usage "no icon name provided"; fi
            icon_name="$3"
        fi

    elif [ "$app_command" == "unset" ]; then
        if [ "$desktop_file" ]; then
            if [ "$2" ]; then exit_bad_usage "second argument not expected"; fi
        fi
        if [ "$path_to_icons" ]; then
            if [ ! "$2" ]; then exit_bad_usage "no icon name provided"; fi
            if [ "$3" ];   then exit_bad_usage "third argument not expected"; fi
            icon_name="$2"
        fi
    elif [ "$app_command" == "list" ]; then
        if [ "$2" ]; then exit_bad_usage "second argument not expected"; fi
    fi

    # Validating the path to the icons directory (if provided)
    if [ "$path_to_icons" ]; then
        if [ $(basename $path_to_icons) != "icons" ]; then
            exit_invalid "icons directory '$path_to_icons' must be named 'icons'"
        elif [ ! -d "$path_to_icons/hicolor" ]; then
            exit_invalid \
            "'$path_to_icons' must have a 'hicolor' directory (https://askubuntu.com/q/300126)"
        fi
        path_to_icons="$path_to_icons/hicolor"
    fi

    # At this point, all the arguments are validated
}

# For .desktop entries information refer to:
# https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#desktop-file-id
function find_path_to_icons() {
    # 'desktop_file' must be defined at this point
    local applications_path=${desktop_file%/*}
    path_to_icons="$applications_path/../icons/hicolor"

    if [ ! -d "$path_to_icons" ]; then
        exit_error "directory '$path_to_icons' not found"
    fi
}

# Get all the directories in XDG_DATA_DIRS
# (XDG_DATA_DIRS is a colon-separated list of directories)
# For more information refer to:
# https://specifications.freedesktop.org/menu-spec/menu-spec-latest.html#paths
function list_applications_in_system() {
    local data_dirs=$(printenv | grep XDG_DATA_DIRS)
    local all_desktop_files=""
    for data_dir in $(echo $data_dirs | sed "s/:/ /g"); do
        data_dir="${data_dir%*/}"
        # Find all '.desktop' entries in the '$data_dir'
        # Redirect `stderr` to '/dev/null' because not all directories always exist
        for desk_file in $(ls $data_dir/applications 2> /dev/null); do
            all_desktop_files+=" $data_dir/applications/$desk_file"
        done
    done
    # Replace spaces with new lines
    echo $all_desktop_files | sed "s/ /\n/g"
}

function usage() {
    echo "
Usage:
  $bin_name (set|unset|list) [options] [<arguments>]

  $bin_name set   <appname.desktop> <icon.png>
  $bin_name set   </path/to/icons>  <icon.png> <icon_name>

  $bin_name unset <appname.desktop>
  $bin_name unset </path/to/icons>  <icon_name>

Commands:
  set    Setup an icon for an application or an icons directory
  unset  Remove an icon for an application or an icons directory
  list   List all the .desktop files in the system and exit.
         Use it with 'grep' to find a specific application.
         Don't use it with 'sudo' or as root.

Options:
  -n, --no-preview  Don't show a preview of the icon when setting it
  -o, --overwrite   Overwrite the icon if it already exists
  -h, --help        Show this help message and exit

Run with sudo when needed.
Refer to https://wiki.archlinux.org/title/desktop_entries
for more information about .desktop files.
"
}

function exit_error() {
    echo "$bin_name: error: $@"
    exit -1
}
function exit_invalid() {
    echo "$bin_name: $@"
    exit -1
}
function exit_bad_usage() {
    echo "$bin_name: bad usage: $@"
    usage
    exit -1
}

main "$@"; exit 0
