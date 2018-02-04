#!/bin/bash

TOKEN="<TOKEN>"
CHAT="<GROUP>"
BOT="https://api.telegram.org/bot${TOKEN}"

getUpdate(){
	command=$(curl -s "${BOT}/getUpdates" | wc -l)
	if [[ $command -eq 100 ]]
	then
		OFFSET=$(curl -s "${BOT}/getUpdates" | jq -r '.result[-1].update_id')
		curl -s "${BOT}/getUpdates?offset=$(($OFFSET + 1))"
	fi
	curl -s "${BOT}/getUpdates"
}

sendMessage(){
	curl -s "${BOT}/sendMessage?chat_id=${CHAT}" --data-urlencode "text=$1"
}

replyMessage(){
	curl -s "${BOT}/sendMessage?chat_id=${CHAT}&reply_to_message_id=$2" --data-urlencode "text=$1"
}

MessageID="0"
while true
do
	Update=$(getUpdate)
	LastMessageTEXT=$(echo $Update | jq -r '.result[-1].message.text')
	LastMessageID=$(echo $Update | jq -r '.result[-1].message.message_id')
	
	if [[ $LastMessageTEXT = "/teste" && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		replyMessage "isso é um teste" $MessageID &> /dev/null
	fi

	if [[ $LastMessageTEXT =~ CM && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		replyMessage "CMLixo" $MessageID &> /dev/null
	fi

	sleep 1
done
