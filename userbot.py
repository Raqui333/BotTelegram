#!/usr/bin/python3.5

# python bot test

import json
import requests
import time

TOKEN = "<TOKEN>"
BOT = "https://api.telegram.org/bot" + TOKEN
MessageID = 0

def getUpdates():
    command = requests.get(BOT + "/getUpdates")
    command_json = json.loads(command.text)
    if len(command_json["result"]) == 100:
        OFFSET = {"offset": + command_json["result"][-1]["update_id"] + 1}
        return requests.get(BOT + "/getUpdates", params=OFFSET).text
    else:
        return requests.get(BOT + "/getUpdates").text

def sendMessage(ChatID, Text):
    MESSAGE = {"chat_id":ChatID,
               "text":Text,
               "parse_mode":"Markdown",
               "disable_web_page_preview":True}
    requests.post(BOT + "/sendMessage", data=MESSAGE)

def getInfo():
    Update = json.loads(getUpdates())
    
    try: Text = Update["result"][-1]["message"]["text"]
    except KeyError: Text = "None"
    
    try: Type = Update["result"][-1]["message"]["chat"]["type"]
    except KeyError: Type = "None"
    
    try: ChatID = Update["result"][-1]["message"]["chat"]["id"]
    except KeyError: ChatID = "None"

    try: ID = Update["result"][-1]["message"]["message_id"]
    except KeyError: ID = "None"

    return Text, Type, ChatID, ID

while True:
    Text, Type, ChatID, ID = getInfo()
    if ID != MessageID:
        if Text == "/teste":
            MessageID = ID
            sendMessage(ChatID, "Teste Noob")
    # sleep to not explode
    time.sleep(1)
