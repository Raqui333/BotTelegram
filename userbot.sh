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

	ChatType=$(echo $Update | jq -r '.result[-1].message.chat.type')

	LastMessageTEXT=$(echo $Update | jq -r '.result[-1].message.text')
	LastMessageID=$(echo $Update | jq -r '.result[-1] | if .message.message_id == null then .callback_query.message.message_id else .message.message_id end')
	LastMessageUSERNAME=$(echo $Update | jq -r '.result[-1] | if .message.from.username == null then .callback_query.message.from.username else .message.from.username end')
	LastMessageFNAME=$(echo $Update | jq -r '.result[-1].message.from.first_name')
	LastMessageLNAME=$(echo $Update | jq -r '.result[-1].message.from.last_name')

	LastReplyTEXT=$(echo $Update | jq -r '.result[-1].message.reply_to_message.text')
	LastReplyID=$(echo $Update | jq -r '.result[-1].message.reply_to_message.message_id')

	LastStickerID=$(echo $Update | jq -r '.result[-1].message.sticker.file_id')

	LastCallBackDATA=$(echo $Update | jq -r '.result[-1].callback_query.data')
	LastCallBackID=$(echo $Update | jq -r '.result[-1].callback_query.id')

	ChatID=$(echo $Update | jq -r '.result[-1] | if .message.chat.id == null then .callback_query.message.chat.id else .message.chat.id end')
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

				curl -s "${BOT}/sendMessage?chat_id=${5}&parse_mode=Markdown&disable_web_page_preview=true&reply_to_message=${4}" --data-urlencode "text=$(echo -e ${3})" 1> /dev/null
			elif [[ "${2}" = "--button" ]]
			then
				## Message with --button
				## Usage: send --msg --button <msg text> <button> <chat id> 
				
				curl -s "${BOT}/sendMessage?chat_id=${5}&parse_mode=Markdown&disable_web_page_preview=true" \
					--data-urlencode "text=$(echo -e ${3})" --data-urlencode "reply_markup={\"inline_keyboard\":${4}}" 1> /dev/null
			else
				## Message
				## Usage: send --msg <msg text> <chat id>

				curl -s "${BOT}/sendMessage?chat_id=${3}&parse_mode=Markdown&disable_web_page_preview=true" --data-urlencode "text=$(echo -e ${2})" 1> /dev/null
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

				curl -s "${BOT}/sendSticker?chat_id=${3}&sticker=${2}" 1> /dev/null
			fi
			;;
	esac
}

edit(){
	case $1 in
		--msg)
			## editMessage
			## Usage: edit --msg <option> or null (see Text)

			if [[ "${2}" = "--button" ]]
			then
				## ReplyMarkup
				## Usage: edit --msg --button <new button> <msg id> <chat id>

				curl -s "${BOT}/editMessageReplyMarkup?chat_id=${5}&message_id=${4}" --data-urlencode "reply_markup={\"inline_keyboard\":${3}}" 1> /dev/null
			else
				## Text
				## Usage: edit --msg <new msg text> <msg id> <chat id>
	
				curl -s "${BOT}/editMessageText?chat_id${4}&parse_mode=Markdown&&disable_web_page_preview=true&message_id=${3}" --data-urlencode "text=$(echo -e ${2})" 1> /dev/null
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

## Buttons
repoButton='[[{"text":"CLICK HERE","url":"t.me/RepoMatrix"},
              {"text":"ADMs","callback_data":"ADMs"}]]'

admsButton='[[{"text":"UDglad Dahaka","url":"t.me/Raqui333"},
              {"text":"CMwise","url":"t.me/CMAngel"},
              {"text":"Anaboth Hekmatyar","url":"t.me/Anaboth"}],
	     [{"text":"BACK","callback_data":"BACK"}]]'

sourceButton='[[{"text":"Source Code","url":"https://github.com/UserUnavailable/ShellBot/blob/master/userbot.sh"},
                {"text":"GitHub","url":"https://github.com/UserUnavailable/ShellBot"}]]'

while true
do
	## Get Information of the chat
	getInfo

	## Bot Options

	## /start
	if [[ $LastMessageTEXT =~ ^(/start(@Raqui333Bot)?) && $ChatType = "private" && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID

		MSG="*Olá*, _${LastMessageFNAME} ${LastMessageLNAME#null}_, @${LastMessageUSERNAME}\n"
		MSG+="esse bot foi feio em \`Shell Script\` por @Raqui333\n"
		MSG+="para saber mais fale com ele no PV"

		send --msg --button "$MSG" "$sourceButton" $ChatID
	fi
	
	## /repo
	if [[ $LastMessageTEXT =~ ^(/repo(@Raqui333Bot)?) && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		
		MSG="*Matrix Repository*\n\n"
		MSG+="Canal do grupo [Matrix](t.me/BemVindoAMatrixv2) com alguns tutoriais sobre linux"

		send --msg --button "$MSG" "$repoButton" $ChatID
	elif [[ $LastCallBackDATA = "ADMs" && $LastCallBackID != $CallBackID ]]
	then
		MessageID=$LastMessageID
		CallBackID=$LastCallBackID
		edit --msg --button "$admsButton" $LastMessageID $ChatID
	elif [[ $LastCallBackDATA = "BACK" && $LastCallBackID != $CallBackID ]]
	then
		MessageID=$LastMessageID
		CallBackID=$LastCallBackID
		edit --msg --button "$repoButton" $LastMessageID $ChatID
	fi

	## Others
	if [[ $LastMessageUSERNAME = "null"  && $LastMessageID != $MessageID ]]
	then
		MessageID=$LastMessageID
		send --msg --reply "Coloque um [username](t.me/Raqui333Bot) por favor" $MessageID $ChatID
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
