#!/usr/bin/python3.5

## import modules
import json
import requests
import time

## Variables default
TOKEN = "<TOKEN>"
BOT = "https://api.telegram.org/bot" + TOKEN

## Variables to not spam
MessageID, cBackID = 0, 0

def getUpdates():
    command = requests.get(BOT + "/getUpdates")
    command_json = json.loads(command.text)
    if len(command_json["result"]) == 100:
        OFFSET = {"offset": + command_json["result"][-1]["update_id"] + 1}
        return requests.get(BOT + "/getUpdates", params=OFFSET).text
    else:
        return requests.get(BOT + "/getUpdates").text

class msg:
    ## sendMessage
    ## Usage: msg.send(chat_id, text)
    def send(ChatID, Text):
        MESSAGE = {"chat_id":ChatID,
                   "text":Text,
                   "parse_mode":"Markdown",
                   "disable_web_page_preview":True}
        requests.post(BOT + "/sendMessage", data=MESSAGE)
    
    ## sendMessage with Reply
    ## Usage: msg.reply(chat_id, text, reply_to_message_id)
    def reply(ChatID, Text, ReplyID):
        MESSAGE = {"chat_id":ChatID,
                   "text":Text,
                   "parse_mode":"Markdown",
                   "disable_web_page_preview":True,
                   "reply_to_message_id":ReplyID}
        requests.post(BOT + "/sendMessage", data=MESSAGE)

    ## sendMessage with Button
    ## Usage: msg.button(chat_id, text, reply_markup)
    def button(ChatID, Text, Button):
        BUTTON = '{"inline_keyboard":' + Button + '}'
        MESSAGE = {"chat_id":ChatID,
                   "text":Text,
                   "parse_mode":"Markdown",
                   "disable_web_page_preview":True,
                   "reply_markup":BUTTON}
        requests.post(BOT + "/sendMessage", data=MESSAGE)

class edit:
    ## editMessage
    ## Usage: edit.button(chat_id, message_id, reply_markup)
    def button(ChatID, ID, Button):
        BUTTON = '{"inline_keyboard":' + Button + '}'
        MESSAGE = {"chat_id":ChatID,
                   "message_id":ID,
                   "reply_markup":BUTTON}
        requests.post(BOT + "/editMessageReplyMarkup", data=MESSAGE)

def getInfo():
    Update = json.loads(getUpdates())
    
    try: Text = Update["result"][-1]["message"]["text"]
    except KeyError: Text = "None"
    
    try: Type = Update["result"][-1]["message"]["chat"]["type"]
    except KeyError: Type = "None"
    
    try: ChatID = Update["result"][-1]["message"]["chat"]["id"]
    except KeyError: 
        try: ChatID = Update["result"][-1]["callback_query"]["message"]["chat"]["id"]
        except KeyError: ChatID = "None"

    try: ID = Update["result"][-1]["message"]["message_id"]
    except KeyError: 
        try: ID = Update["result"][-1]["callback_query"]["message"]["message_id"]
        except KeyError: ID = "None"

    try: Username = Update["result"][-1]["message"]["from"]["username"]
    except KeyError:
        try: Username = Update["result"][-1]["callback_query"]["message"]["from"]["username"]
        except KeyError: Username = "None"

    try: FName = Update["result"][-1]["message"]["from"]["first_name"]
    except KeyError: FName = "None"

    try: LName = Update["result"][-1]["message"]["from"]["last_name"]
    except KeyError: LName = "None"

    try: callbackID = Update["result"][-1]["callback_query"]["id"]
    except KeyError: callbackID = "None"

    try: callbackDATA = Update["result"][-1]["callback_query"]["data"]
    except KeyError: callbackDATA = "None"

    return Text, Type, ChatID, ID, Username, FName, LName, callbackID, callbackDATA

## Buttons
sourceButton = '[[{"text":"Source Code","url":"https://github.com/UserUnavailable/ShellBot/blob/master/userbot.py"}, \
                  {"text":"GitHub","url":"https://github.com/UserUnavailable"}]]'

repoButton='[[{"text":"CLICK HERE","url":"t.me/RepoMatrix"}, \
              {"text":"ADMs","callback_data":"ADMs"}]]'

admsButton='[[{"text":"UDglad Dahaka","url":"t.me/Raqui333"}, \
              {"text":"CMwise","url":"t.me/CMAngel"}, \
              {"text":"Anaboth Hekmatyar","url":"t.me/Anaboth"}], \
	     [{"text":"BACK","callback_data":"BACK"}]]'


while True:
    ## GetInfo
    Text, Type, ChatID, ID, Username, FName, LName, callbackID, callbackDATA = getInfo()
    
    ## to not spam
    if ID != MessageID:
        if Text == "/teste":
            MessageID = ID
            msg.send(ChatID, "Teste Noob")

        if Username == "None":
            MessageID = ID
            msg.reply(ChatID, "Coloca um [username](t.me/Raqui333Bot) otário", MessageID)

        if Text == "/start" and Type == "private":
            MessageID = ID

            MSG = "*Olá* _" + FName + " " + LName.replace("None", "") + "_, @" + Username + "\n" \
                  "esse bot foi feito em `Python` por @Raqui333" + "\n" \
                  "para saber mais fale com ele no PV"

            msg.button(ChatID, MSG, sourceButton)
    
    ## Button Repo
    if Text == "/repo" and ID != MessageID:
        MessageID = ID
            
        MSG = "*Matrix Repository*\n\n" \
                  "Canal do grupo [Matrix](t.me/BemVindoAMatrixv2) com alguns tutoriais sobre linux"
        msg.button(ChatID, MSG, repoButton)
    elif callbackDATA == "ADMs" and callbackID != cBackID:
        cBackID = callbackID
        MessageID = ID
        edit.button(ChatID, ID, admsButton)
    elif callbackDATA == "BACK" and callbackID != cBackID:
        cBackID = callbackID
        MessageID = ID
        edit.button(ChatID, ID, repoButton)
    
    # sleep to not explode
    time.sleep(1)
