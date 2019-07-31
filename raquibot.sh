#!/bin/bash

TOKEN="<TOKEN>"
BOT="https://api.telegram.org/bot${TOKEN}"

declare -g DATA
declare -g READ

function set_as_read() {
	READ=$(jq -r '.result[-1].message.message_id' <<< ${DATA})
}

function get_updates() {
	DATA=$(curl -s -X GET ${BOT}/getUpdates)
	if [[ $(wc -l <<< ${DATA}) -ge 100 ]]; then
		OFFSET=$(jq -r '.result[-1].update_id' <<< ${DATA})
		curl -s -d "offset=$((${OFFSET} + 1))" -X POST ${BOT}/getUpdates -o /dev/null
	fi
}

function send_msg() {
	curl -s -d "chat_id=${1}&text=${2}" -X POST ${BOT}/sendMessage -o /dev/null
	set_as_read
}

function send_sticker() {
	curl -s -d "chat_id=${1}&sticker=${2}" -X POST ${BOT}/sendSticker -o /dev/null
	set_as_read
}

while get_updates ; do
	MSG=$(jq -r '.result[-1].message.text' <<< ${DATA})
	CHAT=$(jq -r '.result[-1].message.chat.id' <<< ${DATA})
	ID=$(jq -r '.result[-1].message.message_id' <<< ${DATA})

	if [[ ${ID} != ${READ} ]]; then
		## /base64 command
		if [[ ${MSG} =~ ^/base64(@Raqui333bot)? ]]; then
			MSG=$(sed -E 's:^/base64(@Raqui333bot)?\s::' <<< ${MSG} | tr -d '\n' | base64)
			send_msg ${CHAT} ${MSG}
		fi
		
		## KappaPride
		if [[ ${MSG} =~ KappaPride ]]; then
			send_sticker ${CHAT} "CAADAQADJQcAAsTJswNX-kZLiMEjjRYE"
		fi
	fi

	sleep 0.5
done
