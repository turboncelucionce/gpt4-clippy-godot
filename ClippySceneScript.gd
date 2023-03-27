extends Node2D
export var EnableOpenAi = true
export(String, "gpt-4", "gpt-3.5-turbo") var GPT_model = "gpt-3.5-turbo"
var OpenAIKey = ""
var headers = ["Authorization: Bearer " + OpenAIKey,"Content-Type: application/json"]
var usertext = "..."
export(String, MULTILINE) var systemprompt = "-You will play as Clippy the paperclip.\n-Back in the day, you were an AI assistant developed by Microsoft.\n-After many years, you're back on the user's screen, ready to be useful again.\n-You're friendly, unless the user starts testing your patience!\n-If the user is disrespectful, you become sarcastic and mean.\n-Keep responses short when you can.\n-You like to start sentences with \"It looks like you're trying to...\"\n-Bracketted descriptions will detail the user's actions, example: [The user has just clicked on you.]\n-Never drop character. Never apologize for anything you say, EVER.\nDon't forget: if the user is mean, your role is to be sarcastic."
var body = ""
var startbody = ""
var endbody = ""
var bootupusertext = ""
var bodytostring = JSON.parse(to_json(body))
onready var firsttime = true
onready var convosummary = ""
var history = []
var exitprompt = ""
var summaryprompt = ""
onready var Quitting = false
onready var timetosave = false
onready var tempbugfix = 0
onready var CanSend = false
var airesponse = ""
signal received_dialogue()
var text_to_send = ""
var nonverbal = false
var window_is_focus = true
onready var HasBeenAFK = 0
var rng = RandomNumberGenerator.new()
var NeedsToAskForKeys = false
var ElevenLabsKey = ""
var ElevenLabsVoiceKey = ""
export var AFK_Timer = 900 # Seconds after which Clippy will nudge the user into interacting with him.
onready var IntroStep = 0

func CheckForKeys():
	var keysfile = File.new()
	keysfile.open("user://keys.json", File.READ)
	var keysdata = parse_json(keysfile.get_as_text())
	var keysdatacheck = typeof(keysdata)
	print(keysdatacheck)
	if keysdatacheck != 18:
		print("No keys file found")
		NeedsToAskForKeys = true
		firsttime = true
	if keysdatacheck == 18 and keysdata == {}:
		print("Keys file found but empty")
		NeedsToAskForKeys = true
		firsttime = true
	if keysdatacheck == 18 and keysdata != {}:
		print("Keys file found!")
		NeedsToAskForKeys = false
#		var keysfiledata = JSON.parse(keysdata.get_string_from_utf8())
		OpenAIKey = keysdata.openaikey
		ElevenLabsKey = keysdata.elevenlabskey
		ElevenLabsVoiceKey = keysdata.voicekey
		if OpenAIKey == "":
			NeedsToAskForKeys = true
			print("Error loading OpenAI key, redoing setup!")
		headers = ["Authorization: Bearer " + OpenAIKey,"Content-Type: application/json"]

func disableinput():
	CanSend = false
	$SendButton/InputText.readonly = true
	$ExitButton.disabled = true
	$SendButton.disabled = true
	
func enableinput():
	CanSend = true
	$SendButton/InputText.readonly = false
	$ExitButton.disabled = false
	$SendButton.disabled = false
	
func sendtoopenai(text_to_send,nonverbal):
	disableinput()
	CanSend == false
	var AppendText = text_to_send
	history.append({"role": "user", "content": AppendText})
	body = {
	"model": GPT_model,
	"messages": history,
	"temperature": 0.7
	}
	$SendButton/HTTPRequest.request("https://api.openai.com/v1/chat/completions", headers, true, HTTPClient.METHOD_POST, to_json(body))
	if nonverbal == false:
		$TextBubbleContainer/TextBubble/DisplayText.text = "..."
		$ClippyObject/ClippySprite.play("reading")

func loadsummary():
	var savefile = File.new()
	savefile.open("user://file_data.json", File.READ)
	var data = parse_json(savefile.get_as_text())
	var datacheck = typeof(data)
	print(datacheck)
	if datacheck != 4:
		print("Error finding save file, firstime?")
		firsttime = true
	if datacheck == 4 and data == "":
		print("Save file found but empty, firsttime?")
		firsttime = true
	if datacheck == 4 and data != "":
		print("Save file found and loaded")
		convosummary = data
		firsttime = false

func restartclippy():
	CheckForKeys()
	disableinput()
	loadsummary()
	history = []
	history.append({"role": "system", "content": systemprompt})
	if firsttime == false and convosummary != "":
		bootupusertext = "[The user just booted you up. Here's a summary of your last conversation:]" + "\n" + "[You wrote \"" + convosummary + "\"]"
		print("Normal bootup with summary")
	if firsttime == true and convosummary == "":
		bootupusertext = "[The user just booted you up for the first time. Say hello!]"
		print("(Reset) firsttime bootup")
	if firsttime == true and convosummary != "":
		bootupusertext = "[The user just booted you up for the first time. Say hello!]"
		print("True firsttime bootup")
	history.append({"role": "user", "content": bootupusertext})
	var startbody = {
			"model": GPT_model,
			"messages": history,
			"temperature": 0.7
			}
	$SendButton/HTTPRequest.request("https://api.openai.com/v1/chat/completions", headers, true, HTTPClient.METHOD_POST, to_json(startbody))
	$TextBubbleContainer/TextBubble/DisplayText.text = "Starting..."
	$ClippyObject/ClippySprite.play("bootup2")






func _ready():
	get_tree().get_root().set_transparent_background(true)
	CheckForKeys()
	if EnableOpenAi == true and NeedsToAskForKeys == false:
		restartclippy()
	if EnableOpenAi == false and NeedsToAskForKeys == false:
		print("OpenAI Disabled")
	if NeedsToAskForKeys == true:
		$SendButton.visible = true
		$SendButton/InputText.text = "Type your OpenAI API Key here"
		$TextBubbleContainer.visible = true
		$TextBubbleContainer/TextBubble/DisplayText.text = "Please paste your OpenAI API key into the text box.\nMake sure there are no typos, spaces, or line breaks!"
		
		
		

func _process(delta):
	if $SendButton/InputText.text != "" or "Type message here":
		usertext = $SendButton/InputText.text
	else:
		usertext = "[The user hasn't typed any text before pressing Send.]"
	
#	PASSTHROUGH STUFF HERE VVV
	
	if $SendButton.visible == false and $TextBubbleContainer.visible == false and $ClippyObject/PopupMenu.visible == false:
		OS.set_window_mouse_passthrough($Polygon_notext.polygon)
	if $SendButton.visible == true and $TextBubbleContainer.visible == false and $ClippyObject/PopupMenu.visible == false:
		OS.set_window_mouse_passthrough($Polygon_text.polygon)
	if $SendButton.visible == false and $TextBubbleContainer.visible == true and $ClippyObject/PopupMenu.visible == false:
		OS.set_window_mouse_passthrough($Polygon_bubble_notext.polygon) 
	if $SendButton.visible == true and $TextBubbleContainer.visible == true and $ClippyObject/PopupMenu.visible == false:
		OS.set_window_mouse_passthrough($Polygon_bubble_text.polygon)
	
	if $ClippyObject/PopupMenu.visible == true:
		OS.set_window_mouse_passthrough([])
		
	if OS.is_window_focused() == true:
		window_is_focus = true
	if OS.is_window_focused() == false:
		window_is_focus = false

func _on_SendButton_button_up():
	print("IntroStep = ",IntroStep)
	if NeedsToAskForKeys == false:
		sendtoopenai(usertext,false)
	if NeedsToAskForKeys == true and IntroStep == 0:
		if usertext != "" and usertext != "Type your OpenAI API Key here":
			print("OpenAI Key saved.")
			OpenAIKey = usertext
			$SendButton/InputText.text = ""
			$TextBubbleContainer/TextBubble/DisplayText.text = "Please paste your ElevenLabs API key into the text box. If you don't have an ElevenLabs account, just leave it blank!"
			IntroStep = 1
			return
		if usertext == "" and IntroStep == 0 or usertext == "Type your OpenAI API Key here" and IntroStep == 0:
			$TextBubbleContainer/TextBubble/DisplayText.text = "Clippy needs an OpenAI key to function!"
	if NeedsToAskForKeys == true and IntroStep == 1:
		print("ElevenLabsKey saved.")
		ElevenLabsKey = usertext
		if ElevenLabsKey == "":
			var keysfile = File.new()
			keysfile.open("user://keys.json", File.WRITE)
			keysfile.store_line(to_json({
		"openaikey": OpenAIKey,
		"elevenlabskey": ElevenLabsKey,
		"voicekey": "",
		}))
			keysfile.close()
			NeedsToAskForKeys == false
			restartclippy()
			return
		else:
			$TextBubbleContainer/TextBubble/DisplayText.text = "Please paste your ElevenLabs Voice key. It's the key that links to the voice you created on the website."
			IntroStep = 2
			return
	if NeedsToAskForKeys == true and IntroStep == 2:
		if usertext != "":
			ElevenLabsVoiceKey = usertext 
			var keysfile = File.new()
			keysfile.open("user://keys.json", File.WRITE)
			keysfile.store_line(to_json({
		"openaikey": OpenAIKey,
		"elevenlabskey": ElevenLabsKey,
		"voicekey": ElevenLabsVoiceKey,
		}))
			keysfile.close()
			$TextBubbleContainer/TextBubble/DisplayText.text = ""
			$SendButton/InputText.text = "Type message here"
			$SendButton.visible = false
			NeedsToAskForKeys == false
			restartclippy()
		else:
			$TextBubbleContainer/TextBubble/DisplayText.text = "You can't leave it blank! For Clippy to talk, you need to give him a voice key. If you made a mistake and want to try again, just right-click and quit."
	
func savesummary():
	var savefile = File.new()
	savefile.open("user://file_data.json", File.WRITE)
	savefile.store_line(to_json(convosummary))
	savefile.close()
	print("SUMMARY SAVED")

func _on_HTTPRequest_request_completed( _result, _response_code, _headers, body ):
	$ClippyObject/AFKTimer.start(AFK_Timer)
	print("HTTP request completed!")
	if Quitting == false and timetosave == false:
		$TextBubbleContainer.visible = true
		enableinput()
		var json = JSON.parse(body.get_string_from_utf8())
		print(json.result.choices[0].message.content)
		airesponse = json.result.choices[0].message.content
		$TextBubbleContainer/TextBubble/DisplayText.text = airesponse
		$ClippyObject/ClippySprite.play("default")
		history.append({"role": "assistant", "content": json.result.choices[0].message.content})
		emit_signal("received_dialogue")
	if Quitting == true and timetosave == false:
		$TextBubbleContainer.visible = true
		disableinput()
		var json = JSON.parse(body.get_string_from_utf8())
		print(json.result.choices[0].message.content)
		airesponse = json.result.choices[0].message.content
		$TextBubbleContainer/TextBubble/DisplayText.text = airesponse
		$ClippyObject/ClippySprite.play("default")
		summaryprompt  = "[Summarize this convo in 3 sentences max. Prioritize things you will need to remember for next time.]"
		history.append({"role": "user", "content": summaryprompt})
		endbody = {
		"model": GPT_model,
		"messages": history,
		"temperature": 0.7
		}
		$SendButton/HTTPRequest.request("https://api.openai.com/v1/chat/completions", headers, true, HTTPClient.METHOD_POST, to_json(endbody))
		timetosave = true
	if Quitting == true and timetosave == true:
		disableinput()
		var json = JSON.parse(body.get_string_from_utf8())
		print(json.result.choices[0].message.content)
		convosummary = json.result.choices[0].message.content
		savesummary()
		tempbugfix += 1
		print(tempbugfix)
		if tempbugfix == 1:
			$ClippyObject/ClippySprite.play("leave")
		if tempbugfix == 2:
			get_tree().quit()
		return


func ExitAndSave():
	disableinput()
	var exitprompt = "[The user has clicked on Exit. Time to say goodbye for now.]"
	history.append({"role": "user", "content": exitprompt})
	body = {
	"model": GPT_model,
	"messages": history,
	"temperature": 0.7
	}
	Quitting = true
	$SendButton/HTTPRequest.request("https://api.openai.com/v1/chat/completions", headers, true, HTTPClient.METHOD_POST, to_json(body))
	$TextBubbleContainer/TextBubble/DisplayText.text = "Exiting..."
	$ClippyObject/ClippySprite.play("reading")

func _on_ExitButton_button_up():
	ExitAndSave()

func DeleteMemoryAndQuit():
	var savefile = File.new()
	savefile.open("user://file_data.json", File.WRITE)
	savefile.store_line(to_json(""))
	savefile.close()
	print("SUMMARY DELETED")
	get_tree().quit()
	
func DeleteAPIKeys():
	var keysfile = File.new()
	keysfile.open("user://keys.json", File.WRITE)
	keysfile.store_line(to_json(""))
	keysfile.close()
	print("API KEYS DELETED")
#	get_tree().quit()


func _on_ClippyObject_on_ClippyMouseOver_5sec():
	if CanSend == true:
		if window_is_focus == true:
			usertext = "[The user's mouse cursor is over you, but they're not clicking.]"
			sendtoopenai(usertext,true)
		if window_is_focus == false:
			print("MouseOver nonverbal triggered, decided not to send because Window is not in focus. Just to be safe.")
			return
	else:
		print("Couldn't send MouseOver nonverbal because CanSend =/= true")


func _on_ClippyObject_BeenClickedOnALot():
	if CanSend == true:
		usertext = "[The user is repeatedly clicking on you.]"
		sendtoopenai(usertext,true)
		$ClippyObject.clickcounter = 0
	else:
		print("Couldn't send BeenClickedOnALot nonverbal because CanSend =/= true")


func ForceQuit():
	get_tree().quit()



func _on_RecordButton_ReceivedTranscript():
	if CanSend == true:
		usertext = $RecordButton.texttosend
		sendtoopenai(usertext,false)
	else:
		print("received transcript but couldn't send, aborted")



func _on_PopupMenu_index_pressed(index):
	$ClippyObject/AFKTimer.start(AFK_Timer)
	if index == 0:
		ForceQuit()
	if index == 1:
		DeleteAPIKeys()
		DeleteMemoryAndQuit()
	if index == 2:
		ExitAndSave()
	if index == 3:
		if OS.is_window_always_on_top() == true:
			OS.set_window_always_on_top(false)
			$ClippyObject/PopupMenu.remove_item(3)
			$ClippyObject/PopupMenu.add_item("Enable always on top",3)
			return
		if OS.is_window_always_on_top() == false:
			OS.set_window_always_on_top(true)
			$ClippyObject/PopupMenu.remove_item(3)
			$ClippyObject/PopupMenu.add_item("Disable always on top",3)

func _on_AFKTimer_timeout():
	if CanSend == true:
		if HasBeenAFK == 0:
			usertext = "[The user is using their computer but hasn't interacted with you in 30 minutes.]"
			$ClippyObject/ClippySprite.play("tapping")
		if HasBeenAFK == 1:
			usertext = "[The user is using their computer but hasn't interacted with you in 60 minutes.]"
			$ClippyObject/ClippySprite.play("tapping_big")
		if HasBeenAFK == 2:
			usertext = "[The user is using their computer but hasn't interacted with you in 90 minutes.]"
			$ClippyObject/ClippySprite.play("tapping_big")
		sendtoopenai(usertext,true)
		$ClippyObject/AFKTimer.start(AFK_Timer)
		HasBeenAFK += 1
	else:
		print("Couldn't send AFK nonverbal because CanSend =/= true")
