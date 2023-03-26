extends Button
#var http_request = HTTPRequest.new()
#
## Declare member variables here. Examples:
## var a = 2
## var b = "text"
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta):
##	pass
#
#func deletechild(_a, _b, _c, _d, child):
#	child.queue_free()
#
#func fetch(url:String = "https://www.duckduckgo.com", headers:Array = [], method = HTTPClient.METHOD_GET, callback:String = "AAA", body = null):
#	if url == null or url == "":
#		return null
#	var http_request = HTTPRequest.new()
#	add_child(http_request)
#	http_request.connect("request_completed", self, callback)
#	http_request.connect("request_completed", self, "deletechild", [http_request])
#	var req
#	if body != null:
#		req = http_request.request(url, headers, true, method, body)
#	else:
#				req = http_request.request(url, headers, true, method)
#	if req != OK:
#		return "error"
#
#func handle_response(result, response_code, headers, body):
#	var response = parse_json(body.get_string_from_utf8())
#
#func _Get_Api_Data():
#	fetch("https://jsonplaceholder.typicode.com/todos/1")
#
#
#func _on_HTTPRequest_request_completed(result, response_code, headers, body):
#	$RichTextLabel.text = "BLABLA"
#	pass # Replace with function body.

func _ready():
	pass

func _on_Button_pressed():
	$HTTPRequest.request("http://www.mocky.io/v2/5185415ba171ea3a00704eed")

func _on_HTTPRequest_request_completed( result, response_code, headers, body ):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
