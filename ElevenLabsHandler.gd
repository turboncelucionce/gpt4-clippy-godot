extends Node2D
var InputPhrase = ""
#export(String, "Char 1", "Char 2", "Char 3", "Char 4", "Char 5", "Char 6") var CharacterVoice = "Char 1"
export var ElevenAIAPIKey = ""
var EnableElevenLabs = false
export var ElevenAIVoiceKey = ""
var ElevenHeaders = ["accept: audio/mpeg", xiapikey,"Content-Type: application/json"]
var ElevenBody = ""
export var ForceDisableElevenLabs = false
onready var ClippyScene = get_node("/root/ClippyScene")
var xiapikey = ""

func _ready():
#	if EnableElevenLabs == true:
#		if CharacterVoice == "Char 1":
#			ElevenAIVoiceKey = ""
#		if CharacterVoice == "Char 2":
#			ElevenAIVoiceKey = ""
#		if CharacterVoice == "Char 3":
#			ElevenAIVoiceKey = ""
#		if CharacterVoice == "Char 4":
#			ElevenAIVoiceKey = ""
#		if CharacterVoice == "Char 5":
#			ElevenAIVoiceKey = ""
#		if CharacterVoice == "Char 6":
#			ElevenAIVoiceKey = ""
#		print("Voice set as " + CharacterVoice)
#	else:
#		print("ElevenLabs disabled.")
	pass

func _process(delta):
	if ForceDisableElevenLabs == true:
		EnableElevenLabs = false
	else:
		ElevenAIAPIKey = ClippyScene.ElevenLabsKey
		ElevenAIVoiceKey = ClippyScene.ElevenLabsVoiceKey
		if ElevenAIAPIKey == "" or ElevenAIVoiceKey == "":
			EnableElevenLabs = false
		else:
			EnableElevenLabs = true
			xiapikey = "xi-api-key: " + ElevenAIAPIKey + ""
			ElevenHeaders = ["accept: audio/mpeg", xiapikey,"Content-Type: application/json"]


func _on_ClippyScene_received_dialogue():
	InputPhrase = ClippyScene.airesponse
	var ElevenBody = {
  "text": InputPhrase,
  "voice_settings": {
	"stability": 0.5,
	"similarity_boost": 1
  }
}
	if EnableElevenLabs == true:
		print("Sending ElevenLabs request...")
		$HTTPRequest2.request("https://api.elevenlabs.io/v1/text-to-speech/"+ElevenAIVoiceKey, ElevenHeaders, true, HTTPClient.METHOD_POST, to_json(ElevenBody))


func _on_HTTPRequest2_request_completed( _result, _response_code, _headers, ElevenBody ):
	print("Request completed!")
#	var bodytype = typeof(ElevenBody)
#	print(bodytype)
#	save(ElevenBody)
	var streammp3 = AudioStreamMP3.new()
	streammp3.data = ElevenBody
	var streamplayer = $AudioStreamPlayer
	streamplayer.stream = streammp3
	streamplayer.play()


#func save(content):
#	var OutputFile = File.new()
#	OutputFile.open("user://sound_data.mp3", File.WRITE)
#	OutputFile.store_buffer(content)
#	OutputFile.close()
