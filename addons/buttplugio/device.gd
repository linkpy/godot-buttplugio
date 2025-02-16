## Interface to a Buttplug.IO device.
##
class_name BPIODevice extends RefCounted


const _BPIOMessage = preload("res://addons/buttplugio/protocol/message.gd")



var name: String:
	get: return _name

var display_name: String:
	get: return _display_name

var device_index: int:
	get: return _device_index



func is_device_connected() -> bool:
	return _device_index >= 0



func get_vibrator_count() -> int:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return 0

	if _does_support_message("ScalarCmd"):
		return _get_message_features("ScalarCmd").size()
	else:
		return 0

func get_vibrator_descriptor(idx: int) -> String:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return ""
	
	if not _does_support_message("ScalarCmd"):
		push_error("[BPIO] This device doesnt has any vibrator.")
		return ""
	
	var features := _get_message_features("ScalarCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a vibrator out-of-bound.")
		return ""
	
	return features[idx].feature_descriptor

func get_vibrator_step_count(idx: int) -> int:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return 0
	
	if not _does_support_message("ScalarCmd"):
		push_error("[BPIO] This device doesnt has any vibrator.")
		return 0
	
	var features := _get_message_features("ScalarCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a vibrator out-of-bound.")
		return 0
	
	return features[idx].step_count

func get_vibrator_type(idx: int) -> String:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return ""
	
	if not _does_support_message("ScalarCmd"):
		push_error("[BPIO] This device doesnt has any vibrator.")
		return ""
	
	var features := _get_message_features("ScalarCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a vibrator out-of-bound.")
		return ""
	
	return features[idx].actuator_type



func get_translator_count() -> int:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return 0
	if _does_support_message("LinearCmd"):
		return _get_message_features("LinearCmd").size()
	else:
		return 0

func get_translator_descriptor(idx: int) -> String:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return ""
	
	if not _does_support_message("LinearCmd"):
		push_error("[BPIO] This device doesnt has any translator.")
		return ""
	
	var features := _get_message_features("LInearCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a translator out-of-bound.")
		return ""
	
	return features[idx].feature_descriptor

func get_translator_step_count(idx: int) -> int:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return 0
	
	if not _does_support_message("LinearCmd"):
		push_error("[BPIO] This device doesnt has any translator.")
		return 0
	
	var features := _get_message_features("LinearCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a translator out-of-bound.")
		return 0
	
	return features[idx].step_count

func get_translator_type(idx: int) -> String:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return ""
	
	if not _does_support_message("LinearCmd"):
		push_error("[BPIO] This device doesnt has any translator.")
		return ""
	
	var features := _get_message_features("LinearCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a translator out-of-bound.")
		return ""
	
	return features[idx].actuator_type



func get_rotator_count() -> int:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return 0

	if _does_support_message("RotateCmd"):
		return _get_message_features("RotateCmd").size()
	else:
		return 0

func get_rotator_descriptor(idx: int) -> String:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return ""
	
	if not _does_support_message("RotateCmd"):
		push_error("[BPIO] This device doesnt has any rotator.")
		return ""
	
	var features := _get_message_features("RotateCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a rotator out-of-bound.")
		return ""
	
	return features[idx].feature_descriptor

func get_rotator_step_count(idx: int) -> int:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return 0
	
	if not _does_support_message("RotateCmd"):
		push_error("[BPIO] This device doesnt has any rotator.")
		return 0
	
	var features := _get_message_features("RotateCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a rotator out-of-bound.")
		return 0
	
	return features[idx].step_count

func get_rotator_type(idx: int) -> String:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return ""
	
	if not _does_support_message("RotateCmd"):
		push_error("[BPIO] This device doesnt has any rotator.")
		return ""
	
	var features := _get_message_features("RotateCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a rotator out-of-bound.")
		return ""
	
	return features[idx].actuator_type



func get_sensor_count() -> int:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return 0

	if _does_support_message("SensorReadCmd"):
		return _get_message_features("SensorReadCmd").size()
	else:
		return 0
	
func get_sensor_descriptor(idx: int) -> String:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return ""
	
	if not _does_support_message("SensorReadCmd"):
		push_error("[BPIO] This device doesnt has any sensor.")
		return ""
	
	var features := _get_message_features("SensorReadCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a sensor out-of-bound.")
		return ""
	
	return features[idx].feature_descriptor

func get_sensor_type(idx: int) -> String:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return ""
	
	if not _does_support_message("SensorReadCmd"):
		push_error("[BPIO] This device doesnt has any sensor.")
		return ""
	
	var features := _get_message_features("SensorReadCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a sensor out-of-bound.")
		return ""
	
	return features[idx].sensor_type

func get_sensor_range(idx: int) -> Array:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return [0,0]
	
	if not _does_support_message("SensorReadCmd"):
		push_error("[BPIO] This device doesnt has any sensor.")
		return [0,0]
	
	var features := _get_message_features("SensorReadCmd")
	
	if idx < 0 or idx >= features.size():
		push_error("[BPIO] Trying to access a sensor out-of-bound.")
		return [0,0]
	
	return features[idx].sensor_range



func has_sensor_data(sensor: int) -> bool:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return false
	
	return _sensor_data.has(sensor)

func get_sensor_data(sensor: int) -> Array[int]:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return []
	
	return _sensor_data.get(sensor, [])



func stop() -> void:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return
	
	if not _messages.get("StopDeviceCmd", false):
		push_error("[BPIO] Trying to stop a device not supporting stops.")
		return
	
	var msg := _BPIOMessage.MessageStopDeviceCmd.new()
	msg.index = _device_index
	_queue_message(msg)

func vibrate(vibrator: int, value: float) -> void:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return
	
	if get_vibrator_count() == 0:
		push_error("[BPIO] Trying to vibrate a device without any vibrator.")
		return

	if vibrator == -1:
		for i in range(get_vibrator_count()):
			vibrate(i, value)
	
	else:
		var features := _get_message_features("ScalarCmd")
		if vibrator < 0 or vibrator >= features.size():
			push_error("[BPIO] Trying to vibrate a device with an out-of-bound vibrator index.")
			return
		
		if _message_scalar == null:
			_message_scalar = _BPIOMessage.MessageScalarCmd.new()
			_message_scalar.device_index = _device_index
			
		else:
			for scalar in _message_scalar.scalars:
				if scalar.index == vibrator:
					scalar.scalar = value
					return
		
		var scalar := _BPIOMessage.Scalar.new()
		scalar.index = vibrator
		scalar.scalar = value
		scalar.actuator_type = features[vibrator].actuator_type
		_message_scalar.scalars.push_back(scalar)

func translate(translator: int, duration: float, position: float) -> void:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return
	
	if get_translator_count() == 0:
		push_error("[BPIO] Trying to translate a device without any translator.")
		return

	if translator == -1:
		for i in range(get_translator_count()):
			translate(i, duration, position)
	
	else:
		var features := _get_message_features("LinearCmd")
		if translator < 0 or translator >= features.size():
			push_error("[BPIO] Trying to translate a device with an out-of-bound translator index.")
			return
		
		if _message_linear == null:
			_message_linear = _BPIOMessage.MessageLinearCmd.new()
			_message_linear.device_index = _device_index
			
		else:
			for vector in _message_linear.vectors:
				if vector.index == translator:
					vector.duration = round(duration * 1000)
					vector.position = position
					return
		
		var vector := _BPIOMessage.Vector.new()
		vector.index = translator
		vector.duration = round(duration * 1000)
		vector.position = position
		_message_linear.vectors.push_back(vector)

func rotate(rotator: int, speed: float, clockwise: bool) -> void:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return
	
	if get_rotator_count() == 0:
		push_error("[BPIO] Trying to rotate a device without any rotator.")
		return
	
	if rotator == -1:
		for i in range(get_rotator_count()):
			rotate(i, speed, clockwise)
	
	else:
		var features := _get_message_features("RotateCmd")
		if rotator < 0 or rotator >= features.size():
			push_error("[BPIO] Trying to rotate a device with an out-of-bound rotator index.")
			return
		
		if _message_rotate == null:
			_message_rotate = _BPIOMessage.MessageRotateCmd.new()
			_message_rotate.device_index = _device_index
		
		else:
			for rotation in _message_rotate.rotations:
				if rotation.index == rotator:
					rotation.speed = speed
					rotation.clockwise = clockwise
					return
		
		var rotation := _BPIOMessage.Rotation.new()
		rotation.index = rotator
		rotation.speed = speed
		rotation.clockwise = clockwise
		_message_rotate.rotations.push_back(rotation)

func read_sensor(sensor: int) -> Array:
	if not is_device_connected():
		push_error("[BPIO] Trying to use a disconnected device.")
		return []
	
	if get_sensor_count() == 0:
		push_error("[BPIO] Trying to read sensor from a device without any.")
		return []

	var features = _get_message_features("SensorReadCmd")
	
	var msg := _BPIOMessage.MessageSensorReadCmd.new()
	msg.device_index = _device_index
	msg.sensor_index = sensor
	msg.sensor_type = features[sensor].sensor_type
	var reply := await _queue_message_and_await(msg) as _BPIOMessage.MessageSensorReading
	_sensor_data[sensor] = reply.data
	return reply.data



var _name: String = ""
var _device_index: int = 0
var _message_timing_gap: int = -1
var _display_name: String = ""
var _messages: Dictionary = {}

var _sensor_data: Dictionary = {}

var _client: BPIOClient = null
var _message_queue: Array[_BPIOMessage.OutboundMessage] = []
var _message_scalar: _BPIOMessage.MessageScalarCmd = null
var _message_linear: _BPIOMessage.MessageLinearCmd = null
var _message_rotate: _BPIOMessage.MessageRotateCmd = null
var _last_sent_time: int = 0



func _does_support_message(msg: String) -> bool:
	return _messages.has(msg)

func _get_message_features(msg: String) -> Array[_BPIOMessage.Feature]:
	return _messages[msg]



func _queue_message(msg: _BPIOMessage.OutboundMessage) -> void:
	_message_queue.append(msg)

func _queue_message_with_id(msg: _BPIOMessage.OutboundMessage) -> int:
	var id := _client._socket.increment_next_message_id()
	msg.id = id
	_queue_message(msg)
	return id

func _queue_message_and_await(msg: _BPIOMessage.OutboundMessage) -> _BPIOMessage.InboundMessage:
	var id := _queue_message_with_id(msg)
	return await _await_msg(id, msg.get_message_name())



func _await_msg(id: int, msgname: String) -> _BPIOMessage.InboundMessage:
	while true:
		var msg: _BPIOMessage.InboundMessage = await _client._socket.message_received

		if msg.id == id:
			if msg is _BPIOMessage.MessageError:
				push_error("[BPIO] Error received after sending a ", msgname, " message (ID ", id, "): ", msg.error_message, " (", msg.error_code, ")")
				break
			
			return msg
	
	return null



func _queue_messages_in_client() -> void:
	if _message_timing_gap > 0:
		if Time.get_ticks_msec() < _last_sent_time + _message_timing_gap:
			return

	_client._queue_messages(_message_queue)
	_message_queue.clear()

	if _message_scalar != null:
		_client._queue_message(_message_scalar)
		_message_scalar = null
	
	if _message_linear != null:
		_client._queue_message(_message_linear)
		_message_linear = null
	
	if _message_rotate != null:
		_client._queue_message(_message_rotate)
		_message_rotate = null
	
	_last_sent_time = Time.get_ticks_msec()
