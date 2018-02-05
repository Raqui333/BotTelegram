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
	curl -s "${BOT}/sendMessage?chat_id=${CHAT}&parse_mode=Markdown" --data-urlencode "text=$1"
}

replyMessage(){
	curl -s "${BOT}/sendMessage?chat_id=${CHAT}&reply_to_message_id=$2&parse_mode=Markdown" --data-urlencode "text=$1"
}

MessageID="0"
while true
do
	Update=$(getUpdate)
	
	LastMessageTEXT=$(echo $Update | jq -r '.result[-1].message.text')
	LastMessageID=$(echo $Update | jq -r '.result[-1].message.message_id')
	LastMessageUSERNAME=$(echo $Update | jq -r '.result[-1].message.from.username')

	if [[ $LastMessageTEXT =~ (/teste(@Raqui333Bot)?) && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		replyMessage "isso é um teste, noob" $MessageID &> /dev/null
	fi

	if [[ $LastMessageUSERNAME = "null"  && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		replyMessage "Coloca um [username](tg://user?id=372539286) ai, noob" $MessageID &> /dev/null
	fi

	sleep 1
done
