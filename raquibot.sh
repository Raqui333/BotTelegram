#!/bin/bash

TOKEN="<TOKEN>"
BOT="https://api.telegram.org/bot${TOKEN}"

declare -g DATA5
declare -g ONLY="default"

function get_updates() {
	if [[ $(curl -s "${BOT}/getUpdates" | wc -l) -eq 100 ]]
	then
		OFFSET=$(curl -s "${BOT}/getUpdates" | jq -r '.result[-1].update_id')
		curl -s "${BOT}/getUpdates?offset=$(($OFFSET + 1))"
	fi
	DATA=$(curl -s "${BOT}/getUpdates")
}

function send_msg() {
	curl -s "${BOT}/sendMessage?chat_id=${1}&text=${2}"
	ONLY=$(jq -r '.result[-1].message.message_id' <<< ${DATA})
}

while :; do
	get_updates

	MSG=$(jq -r '.result[-1].message.text' <<< ${DATA})
	CHAT=$(jq -r '.result[-1].message.chat.id' <<< ${DATA})
	
	ID=$(jq -r '.result[-1].message.message_id' <<< ${DATA})

	if [[ $ID != $ONLY ]]
	then
		## /base64 command
		[[ ${MSG} =~ ^/base64(@Raqui333bot)? ]] && send_msg ${CHAT} $(sed -E 's:^/base64(@Raqui333bot)?\s::' <<< ${MSG} | base64)
	fi

	sleep 0.5
done
