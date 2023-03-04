#!/usr/bin/env bash

# note: This script is currently unused

# function parse_i3_status {
#     read version
#     read open_brackets
#     echo $version
#     echo $open_brackets

#     while true
#     do
#         read line
#         LG=$(setxkbmap -query | awk '/layout/{print $2}')
#         if [ $LG == "br" ]
#         then
#             dat="{\"full_text\":\"LANG: $LG\",\"color\":\"#009E00\"}"
#         else
#             dat="{\"full_text\":\"LANG: $LG\",\"color\":\"#C60101\"}"
#         fi
#         echo "${line%?},$dat]" || exit 1
#     done
# }

# # pipe to do block
# i3status --config ~/.config/i3status/config | parse_i3_status

function update_holder {

  local instance="$1"
  local replacement="$2"
  echo "$json_array" | jq --argjson arg_j "$replacement" "(.[] | (select(.instance==\"$instance\"))) |= \$arg_j"
}

function remove_holder {

  local instance="$1"
  echo "$json_array" | jq "del(.[] | (select(.instance==\"$instance\")))"
}

function hey_man {

  local rand_val=$((RANDOM % 3))
  if [ $rand_val == 1 ] ; then
    local json='{ "full_text": "Hey Man!", "color": "#00FF00" }'
    json_array=$(update_holder holder__hey_man "$json")
  elif [ $rand_val == 0 ] ; then
    local json='{ "full_text": "Hey Man!", "color": "#FF0000" }'
    json_array=$(update_holder holder__hey_man "$json")
  else
    json_array=$(remove_holder holder__hey_man)
  fi
}

i3status --config="~/.config/i3status/config" | (read line; echo "$line"; read line ; echo "$line" ; read line ; echo "$line" ; while true
do
  read line
  json_array="$(echo $line | sed -e 's/^,//')"
  hey_man
  echo ",$json_array" 
done)
