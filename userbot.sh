#!/bin/bash

TOKEN="<TOKEN>"
BOT="https://api.telegram.org/bot${TOKEN}"
MessageID=0

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
	curl -s "${BOT}/sendMessage?chat_id=$3&parse_mode=Markdown" --data-urlencode "text=$1" &> /dev/null
}

replyMessage(){
	curl -s "${BOT}/sendMessage?chat_id=$3&reply_to_message_id=$2&parse_mode=Markdown" --data-urlencode "text=$1" &> /dev/null
}

getInfo(){
	Update=$(getUpdate)

	LastMessageTEXT=$(echo $Update | jq -r '.result[-1].message.text')
	LastMessageID=$(echo $Update | jq -r '.result[-1].message.message_id')
	LastMessageUSERNAME=$(echo $Update | jq -r '.result[-1].message.from.username')
	
	ChatID=$(echo $Update | jq -r '.result[-1].message.chat.id')
}

while true
do
	getInfo

	if [[ $LastMessageTEXT =~ (/teste(@Raqui333Bot)?) && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		replyMessage "isso é um teste, noob" $MessageID $ChatID
	fi

	if [[ $LastMessageUSERNAME = "null"  && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		replyMessage "Coloca um [username](tg://user?id=372539286) ai, noob" $MessageID $ChatID
	fi

	sleep 1
done
