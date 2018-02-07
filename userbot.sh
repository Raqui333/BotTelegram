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

getInfo(){
	Update=$(getUpdate)

	LastMessageTEXT=$(echo $Update | jq -r '.result[-1].message.text')
	LastMessageID=$(echo $Update | jq -r '.result[-1].message.message_id')
	LastMessageUSERNAME=$(echo $Update | jq -r '.result[-1].message.from.username')
	
	LastReplyTEXT=$(echo $Update | jq -r '.result[-1].message.reply_to_message.text')
	LastReplyID=$(echo $Update | jq -r '.result[-1].message.reply_to_message.message_id')

	LastStickerID=$(echo $Update | jq -r '.result[-1].message.sticker.file_id')

	ChatID=$(echo $Update | jq -r '.result[-1].message.chat.id')
}

send(){
	case $1 in
		--msg)
			## sendMessage
			## Usage: send --msg <option> or null (see Message)

			if [[ "${2}" = "--reply" ]]
			then
				## Message with --reply
				## Usage: send --msg --reply <msg text> <reply id> <chat id>

				curl -s "${BOT}/sendMessage?chat_id=${5}&parse_mode=Markdown&reply_to_message=${4}" --data-urlencode "text=$(echo -e ${3})" 1> /dev/null
			elif [[ "${2}" = "--button" ]]
			then
				## Message with --button
				## Usage: send --msg --button <msg text> <button> <chat id> 
				
				curl -s "${BOT}/sendMessage?chat_id=${5}&parse_mode=Markdown" --data-urlencode "text=$(echo -e ${3})" --data-urlencode "reply_markup={\"inline_keyboard\":${4}}" 1> /dev/null
			else
				## Message
				## Usage: send --msg <msg text> <chat id>

				curl -s "${BOT}/sendMessage?chat_id=${4}&parse_mode=Markdown" --data-urlencode "text=$(echo -e ${3})" 1> /dev/null
			fi
			;;
		--stk)
			## sendSticker
			## Usage: send <option> or null (see Sticker)

			if [[ "${2}" = "--reply" ]]
			then
				## Sticker with --reply
				## Usage: send --stk --reply <sticker id> <reply id> <chat id>

				curl -s "${BOT}/sendSticker?chat_id=${5}&sticker=${3}&reply_to_message_id=${4}" 1> /dev/null
			else
				## Sticker
				## Usage: send --stk <sticker id> <chat id>

				curl -s "${BOT}/sendSticker?chat_id=${4}&sticker=${3}" 1> /dev/null
			fi
			;;
	esac
}

########################################################################################################################
##                                                                                                                    ##
## How to create a button                                                                                             ##
##                                                                                                                    ##
## Simple URL Button: [[{"text":"<label text on the button>","url":"<url to be opened when the button is pressed>"}]] ##
##                                                                                                                    ##
## see below link to more information                                                                                 ##
## https://core.telegram.org/bots/api#inlinekeyboardmarkup                                                            ##
##                                                                                                                    ##
########################################################################################################################

## Example
repoButton='[[{"text":"CLICK HERE","url":"https://t.me/RepoMatrix"}]]'

while true
do
	## Get Information of the chat
	getInfo

	## Bot Options

	## /teste
	if [[ $LastMessageTEXT =~ ^(/teste(@Raqui333Bot)?) && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		send --msg "isso é um teste, noob" $MessageID $ChatID
	fi
	
	## /repo
	if [[ $LastMessageTEXT =~ ^(/repo(@Raqui333Bot)?) && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		send --msg --button "Matrix Repository" "$repoButton" $ChatID
	fi

	## Others
	if [[ $LastMessageUSERNAME = "null"  && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		send --msg --reply "Coloca um [username](tg://user?id=372539286) ai, noob" $MessageID $ChatID
	fi

	if [[ $LastStickerID = "CAADAQADBwADKeRxF1CaebLREEjlAg" && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		send --stk --reply "CAADAQADfgQAAoH5Rg4NggvvuKeZYwI" $MessageID $ChatID
	fi

	if [[ $LastMessageTEXT =~ (@Raqui333Bot) && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		send --msg --reply "que tem eu carai? vai se fuder" $MessageID $ChatID
	fi
	
	## sleep for not explode my computer
	sleep 1
done
