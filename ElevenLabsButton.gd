extends Button
var InputPhrase = ""
var ElevenAIAPIKey = "0489703a5b7d41f94d6c60a66f75701c"
var ElevenAIVoiceKey = "Z8q1Sj9l7T7FQ6GeaGOx"
var ElevenHeaders = ["accept: audio/mpeg", "xi-api-key: 0489703a5b7d41f94d6c60a66f75701c","Content-Type: application/json"]
var ElevenBody = ""

func _ready():
	pass

func _process(delta):
	InputPhrase = $TextEdit.text

func _on_Button_button_up():
	print(InputPhrase)
	var ElevenBody = {
  "text": InputPhrase,
  "voice_settings": {
	"stability": 0.5,
	"similarity_boost": 1
  }
}
	$HTTPRequest.request("https://api.elevenlabs.io/v1/text-to-speech/"+ElevenAIVoiceKey, ElevenHeaders, true, HTTPClient.METHOD_POST, to_json(ElevenBody))


func _on_HTTPRequest_request_completed( _result, _response_code, _headers, ElevenBody ):
	print("Request completed!")
	var bodytype = typeof(ElevenBody)
	print(bodytype)
	save(ElevenBody)
	var streammp3 = AudioStreamMP3.new()
	streammp3.data = ElevenBody
	var streamplayer = $AudioStreamPlayer
	streamplayer.stream = streammp3
	streamplayer.play()


func save(content):
	var OutputFile = File.new()
	OutputFile.open("user://sound_data.mp3", File.WRITE)
	OutputFile.store_buffer(content)
	OutputFile.close()
