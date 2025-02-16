## Class containing the Buttplug.IO protocol's messages.
##
class_name BPIOMessages


class Base extends RefCounted:
	var id: int = 0

	func get_message_name() -> String:
		push_error("BPIOMessage.get_message_name not implemented")
		return ""

class InboundMessage extends Base:
	static func from_dict(dict: Dictionary) -> InboundMessage:
		var key := dict.keys()[0] as String
		var val := dict[key] as Dictionary

		var mapping := {
			"Ok": func(): return MessageOk.new(),
			"Error": func(): return MessageError.new(),
			"ServerInfo": func(): return MessageServerInfo.new(),
			"ScanningFinished": func(): return MessageScanningFinished.new(),
			"DeviceList": func(): return MessageDeviceList.new(),
			"DeviceAdded": func(): return MessageDeviceAdded.new(),
			"DeviceRemoved": func(): return MessageDeviceRemoved.new(),
			"SensorReading": func(): return MessageSensorReading.new(),
		}

		if not mapping.has(key):
			push_error("[BPIO] Unrecognized inboud message: ", key)
			return null
		
		var m: InboundMessage = mapping[key].call()
		m.deserialize(val)
		return m
	
	func deserialize(dict: Dictionary) -> void:
		id = dict["Id"] as int

class OutboundMessage extends Base:
	func to_dict() -> Dictionary:
		return {
			get_message_name(): serialize()
		}
	
	func serialize() -> Dictionary:
		return {
			"Id": id
		}



class MessageOk extends InboundMessage:
	func get_message_name() -> String:
		return "Ok"

class MessageError extends InboundMessage:
	var error_message: String = ""
	var error_code: int = 0

	func get_message_name() -> String:
		return "Error"

	func deserialize(dict: Dictionary) -> void:
		super(dict)
		error_message = dict["ErrorMessage"] as String
		error_code = dict["ErrorCode"] as int

class MessageServerInfo extends InboundMessage:
	var server_name: String = ""
	var message_version: int = 0
	var max_ping_time: int = 0

	func get_message_name() -> String:
		return "ServerInfo"
	
	func deserialize(dict: Dictionary) -> void:
		super(dict)
		server_name = dict.get("ServerName", "") as String
		message_version = dict["MessageVersion"] as int
		max_ping_time = dict["MaxPingTime"] as int

class MessageScanningFinished extends InboundMessage:
	func get_message_name() -> String:
		return "ScanningFinished"

class MessageDeviceList extends InboundMessage:
	var devices: Array[Device] = []

	func get_message_name() -> String:
		return "DeviceList"
	
	func deserialize(dict: Dictionary) -> void:
		super(dict)

		for entry in dict["Devices"]:
			var dev := Device.new()
			dev.deserialize(entry)
			devices.push_back(dev)

class MessageDeviceAdded extends InboundMessage:
	var name: String = ""
	var index: int = 0
	var message_timing_gap: int = 0
	var display_name: String = ""
	var messages: Dictionary = {}

	func get_message_name() -> String:
		return "DeviceAdded"

	func deserialize(dict: Dictionary) -> void:
		super(dict)
		name = dict["DeviceName"] as String
		index = dict["DeviceIndex"] as int
		message_timing_gap = dict.get("DeviceMessageTimingGap", 0)
		display_name = dict.get("DeviceDisplayName", "")

		for msg in dict["DeviceMessages"].keys():
			if msg == "StopDeviceCmd":
				messages[msg] = true
				continue

			var raw_features: Array = dict["DeviceMessages"][msg]
			var features: Array[Feature] = []

			for raw_feature: Dictionary in raw_features:
				var feature = Feature.new()
				feature.deserialize(raw_feature)
				features.push_back(feature)
			
			messages[msg] = features

class MessageDeviceRemoved extends InboundMessage:
	var index: int = 0

	func get_message_name() -> String:
		return "DeviceRemoved"
	
	func deserialize(dict: Dictionary) -> void:
		super(dict)
		index = dict["DeviceIndex"] as int

class MessageSensorReading extends InboundMessage:
	var device_index: int = 0
	var sensor_index: int = 0
	var sensor_type: String = ""
	var data: Array = []

	func get_message_name() -> String:
		return "SensorReading"
	
	func deserialize(dict: Dictionary) -> void:
		super(dict)
		device_index = dict["DeviceIndex"] as int
		sensor_index = dict["SensorIndex"] as int
		sensor_type = dict["SensorType"] as String
		data = dict["Data"] as Array



class MessagePing extends OutboundMessage:
	func get_message_name() -> String:
		return "Ping"

class MessageRequestServerInfo extends OutboundMessage:
	var client_name: String = ""
	var message_version: int = 0

	func get_message_name() -> String:
		return "RequestServerInfo"
	
	func serialize() -> Dictionary:
		var d = super()
		d["ClientName"] = client_name
		d["MessageVersion"] = message_version
		return d

class MessageStartScanning extends OutboundMessage:
	func get_message_name() -> String:
		return "StartScanning"

class MessageStopScanning extends OutboundMessage:
	func get_message_name() -> String:
		return "StopScanning"

class MessageRequestDeviceList extends OutboundMessage:
	func get_message_name() -> String:
		return "RequestDeviceList"

class MessageStopDeviceCmd extends OutboundMessage:
	var index: int = 0

	func get_message_name() -> String:
		return "StopDeviceCmd"
	
	func serialize() -> Dictionary:
		var d = super()
		d["DeviceIndex"] = index
		return d

class MessageStopAllDevices extends OutboundMessage:
	func get_message_name() -> String:
		return "StopAllDevices"

class MessageScalarCmd extends OutboundMessage:
	var device_index: int = 0
	var scalars: Array[Scalar] = []

	func get_message_name() -> String:
		return "ScalarCmd"
	
	func serialize() -> Dictionary:
		var d = super()
		d["DeviceIndex"] = device_index
		d["Scalars"] = scalars.map(func(x): return x.serialize())
		return d

class MessageLinearCmd extends OutboundMessage:
	var device_index: int = 0
	var vectors: Array[Vector] = []

	func get_message_name() -> String:
		return "LinearCmd"
	
	func serialize() -> Dictionary:
		var d = super()
		d["DeviceIndex"] = device_index
		d["Vectors"] = vectors.map(func(x): return x.serialize())
		return d

class MessageRotateCmd extends OutboundMessage:
	var device_index: int = 0
	var rotations: Array[Rotation] = []

	func get_message_name() -> String:
		return "RotateCmd"
	
	func serialize() -> Dictionary:
		var d = super()
		d["DeviceIndex"] = device_index
		d["Rotations"] = rotations.map(func(x): return x.serialize())
		return d

class MessageSensorReadCmd extends OutboundMessage:
	var device_index: int = 0
	var sensor_index: int = 0
	var sensor_type: String = ""

	func get_message_name() -> String:
		return "SensorReadCmd"
	
	func serialize() -> Dictionary:
		var d = super()
		d["DeviceIndex"] = device_index
		d["SensorIndex"] = sensor_index
		d["SensorType"] = sensor_type
		return d

class MessageSensorSubscribeCmd extends OutboundMessage:
	var device_index: int = 0
	var sensor_index: int = 0
	var sensor_type: String = ""

	func get_message_name() -> String:
		return "SensorSubscribeCmd"
	
	func serialize() -> Dictionary:
		var d = super()
		d["DeviceIndex"] = device_index
		d["SensorIndex"] = sensor_index
		d["SensorType"] = sensor_type
		return d

class MessageSensorUnsubscribeCmd extends OutboundMessage:
	var device_index: int = 0
	var sensor_index: int = 0
	var sensor_type: String = ""

	func get_message_name() -> String:
		return "SensorUnsubscribeCmd"
	
	func serialize() -> Dictionary:
		var d = super()
		d["DeviceIndex"] = device_index
		d["SensorIndex"] = sensor_index
		d["SensorType"] = sensor_type
		return d



class Device extends RefCounted:
	var name: String = ""
	var index: int = 0
	var message_timing_gap: int = 0
	var display_name: String = ""
	var messages: Dictionary = {}

	func deserialize(dict: Dictionary) -> void:
		name = dict["DeviceName"] as String
		index = dict["DeviceIndex"] as int
		message_timing_gap = dict.get("DeviceMessageTimingGap", 0)
		display_name = dict.get("DeviceDisplayName", "")

		for msg in dict["DeviceMessages"].keys():
			if msg == "StopDeviceCmd":
				messages[msg] = true
				continue

			var raw_features: Array = dict["DeviceMessages"][msg]
			var features: Array[Feature] = []

			for raw_feature: Dictionary in raw_features:
				var feature = Feature.new()
				feature.deserialize(raw_feature)
				features.push_back(feature)
			
			messages[msg] = features

class Feature extends RefCounted:
	var feature_descriptor: String = ""
	var step_count: int = 0
	var actuator_type: String = ""
	var sensor_type: String = ""
	var sensor_range: Array = [] # Array[int]
	var endpoints: Array = [] # Array[String]

	func deserialize(dict: Dictionary) -> void:
		feature_descriptor = dict.get("FeatureDescriptor", "")
		step_count = dict.get("StepCount", 0)
		actuator_type = dict.get("ActuatorType", "")
		sensor_type = dict.get("SensorType", "")
		sensor_range = dict.get("SensorRange", [])
		endpoints = dict.get("Endpoints", [])

class Scalar extends RefCounted:
	var index: int = 0
	var scalar: float = 0
	var actuator_type: String = ""

	func serialize() -> Dictionary:
		return {
			"Index": index,
			"Scalar": scalar,
			"ActuatorType": actuator_type
		}

class Vector extends RefCounted:
	var index: int = 0
	var duration: int = 0
	var position: float = 0

	func serialize() -> Dictionary:
		return {
			"Index": index,
			"Duration": duration,
			"Position": position
		}
	
class Rotation extends RefCounted:
	var index: int = 0
	var speed: float = 0
	var clockwise: bool = false

	func serialize() -> Dictionary:
		return {
			"Index": index,
			"Speed": speed,
			"Clockwise": clockwise,
		}
