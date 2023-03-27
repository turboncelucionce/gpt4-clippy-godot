extends Button

signal ReceivedTranscript
onready var ClippyScene = get_node("/root/ClippyScene")
onready var ClippySprite = get_node("/root/ClippyScene/ClippyObject/ClippySprite")
var arraycounttest = 0
onready var http_client = HTTPClient.new()
onready var record_bus = AudioServer.get_bus_index($AudioStreamRecord.bus)
onready var record = AudioServer.get_bus_effect(record_bus, 0)
var issending = false
var whisper_address = "https://api.openai.com/v1/audio/transcriptions"
var openai_api_key = ""
var boundary = "--------CustomBoundary"
#var WhisperHeaders = ["Authorization: Bearer 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","Content-Type: multipart/form-data"]
var WhisperBody = {
"model": "whisper-1",
"file": "user://record_data.wav",
}
var waitingforresponse = false
var texttosend = ""
var icon_hovered = preload("res://sprite/rec_hover.png")
var icon_default = preload("res://sprite/rec_default.png")
var icon_pressed = preload("res://sprite/rec_pressed.png")
var isrecording = false

func _ready():
	pass # Replace with function body.
	
func SendDataToWhisperApi():
	# Connect to the host
	http_client.connect_to_host("api.openai.com", 443, true)

	# Wait for the connection
	while http_client.get_status() == HTTPClient.STATUS_CONNECTING or http_client.get_status() == HTTPClient.STATUS_RESOLVING:
		http_client.poll()
		yield(get_tree().create_timer(0.1), "timeout")

	# Check the connection status
	if http_client.get_status() != HTTPClient.STATUS_CONNECTED:
		print("Connection failed")
		return

	# Create the form data
	var form_data = PoolByteArray()
	var model_data = str("Content-Disposition: form-data; name=\"model\"\r\n\r\nwhisper-1\r\n").to_ascii()
	form_data.append_array(str("--" + boundary + "\r\n").to_ascii())
	form_data.append_array(model_data)
	form_data.append_array(str("--" + boundary + "\r\n").to_ascii())

	var file_path = "user://record_data.wav"
	var file = File.new()
	file.open(file_path, File.READ)
	var file_data = file.get_buffer(file.get_len())
	file.close()

	var file_header = str("Content-Disposition: form-data; name=\"file\"; filename=\"record_data.wav\"\r\nContent-Type: audio/wav\r\n\r\n").to_ascii()
	form_data.append_array(file_header)
	form_data.append_array(file_data)
	form_data.append_array(str("\r\n--" + boundary + "--\r\n").to_ascii())

	# Create the headers
	var headers = [
		"POST /v1/audio/transcriptions HTTP/1.1",
		"Host: api.openai.com",
		"Authorization: Bearer " + openai_api_key,
		"Content-Type: multipart/form-data; boundary=" + boundary,
		"Content-Length: " + str(form_data.size())
	]

	# Send the request
	http_client.request_raw(HTTPClient.METHOD_POST, "/v1/audio/transcriptions", headers, form_data)

	# Process the response
	var response_body = PoolByteArray()
	var is_response_read = false
	var response_text = ""
	while is_response_read == false and http_client.get_status() != HTTPClient.STATUS_DISCONNECTED:
		http_client.poll()
		yield(get_tree().create_timer(0.1), "timeout")

		if http_client.get_status() == HTTPClient.STATUS_BODY:
			while http_client.get_status() == HTTPClient.STATUS_BODY:
				var chunk = http_client.read_response_body_chunk()
#				print("Chunk size: ", chunk.size())  # Debugging chunk size
#				print(chunk)
				if chunk.size() != 0:
					response_text += chunk.get_string_from_utf8()
					is_response_read = true
					break
				response_body.append(chunk)
				http_client.poll()
				yield(get_tree().create_timer(0.1), "timeout")
		elif http_client.get_status() in [HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_CANT_CONNECT, HTTPClient.STATUS_CANT_RESOLVE]:
			print("Error in connection")
			return

	# Get response status code
	var response_code = http_client.get_response_code()
	print("Whisper response code: ", response_code)

	# Parse the response
#	print("Response: ", response_text)

	var response_json = parse_json(response_text)
	if response_json != null and "text" in response_json:
		print("Transcribed audio: ", response_json["text"])
		texttosend = response_json["text"]
		emit_signal("ReceivedTranscript")
	else:
		print("Error: 'text' field not found in the response or the response is not valid JSON")
	waitingforresponse = false
		

func _on_RecordButton_toggled(button_pressed):
	if button_pressed == true:
		record.set_recording_active(button_pressed)
		print("Starting recording")
		$AudioStreamRecord.play()

	if not button_pressed:
		$TestPlayer.stream = record.get_recording()
		$AudioStreamRecord.stop()
		print("Stopping recording")
		self.disabled
		$TestPlayer.stream.save_to_wav("user://record_data")
		SendDataToWhisperApi()

func _on_RecordButton_button_down():
	record.set_recording_active(true)
	print("Starting recording")
	isrecording = true
	$AudioStreamRecord.play()


func _on_RecordButton_button_up():
	
	$TestPlayer.stream = record.get_recording()
	$AudioStreamRecord.stop()
	print("Stopping recording")
	isrecording = false
	self.disabled
	$TestPlayer.stream.save_to_wav("user://record_data")
	waitingforresponse = true
	SendDataToWhisperApi()
	ClippySprite.animation = "idle_to_exclamation"

func _process(delta):
	openai_api_key = ClippyScene.OpenAIKey
	if ClippyScene.CanSend == true and waitingforresponse == false:
		self.disabled = false
		if self.is_hovered() == true and isrecording == false:
			self.icon = icon_hovered
		if self.is_hovered() == true and isrecording == true:
			self.icon = icon_pressed
		if self.is_hovered() == false and isrecording == false:
			self.icon = icon_default
		return
	else:
		self.disabled = true
