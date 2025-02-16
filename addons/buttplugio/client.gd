## Client for Buttplug.IO. Internally uses [BPIOConnection] and manages 
## the connected devices as [BPIODevice].
##
class_name BPIOClient extends Node

const _BPIOMessage = preload("res://addons/buttplugio/protocol/message.gd")


## The client has connected to a server.
signal connected()
## The client failed to connect to a server.
signal connection_failed(why: String)
## The client has disconnected from a server.
signal disconnected()

## A new device has been connected to the server.
signal device_connected(device: BPIODevice)
## A device has been disconnected from a server.
signal device_disconnected(device: BPIODevice)
## Device scanning has been started on the server.
signal scanning_started()
## Device scanning has finished on the server.
signal scanning_finished()
## Sensor [param data] have been received for the [param device], regarding the
## sensor at index [param sensor].
signal sensor_data_received(device: BPIODevice, sensor: int, data: Array[int])


## Name of the client, reported to the server.
@export var client_name := "Godot.SEX"
## URL to connect to.
@export var server_url := "ws://127.0.0.1:12345"


## Checks if the client is connecting.
func is_client_connecting() -> bool:
    return _socket.is_socket_connecting()

## Checks if the client is fully connected.
func is_client_connected() -> bool:
    return _socket.is_socket_connected()

## Checks if the client is fully disconnected.
func is_client_disconnected() -> bool:
    return _socket.is_socket_disconnected()

## Checks if the client is disconnecting.
func is_client_disconnecting() -> bool:
    return _socket.is_socket_disconnecting()


## Retreives the device with the index [param index].
func get_device(index: int) -> BPIODevice:
    return _devices.get(index, null)


## Connects the client to the server at the URL [param url]. If
## no URL are provided, the URL in [field server_url] is used 
## instead.
func connect_to_server(url: String = "") -> void:
    if not is_client_disconnected():
        push_error("[BPIO] Trying to connect a client not disconnected.")
        return

    if not url.is_empty():
        server_url = url
    
    _message_queue = []
    if _socket.connect_socket(server_url):
        set_process(true)

## Disconnects the client from the server.
func disconnect_from_server() -> void:
    if not is_client_connected():
        push_error("[BPIO] Trying to disconnect a client not connected.")
        return

    _socket.disconnect_socket()



## Requests the server to start scanning for devices.
func start_scanning_for_devices() -> void:
    if not is_client_connected():
        push_error("[BPIO] Trying to send a message on a disconnected client.")
        return
    
    _queue_message(_BPIOMessage.MessageStartScanning.new())
    scanning_started.emit()

## Requests the server to stop scanning for devices.
func stop_scanning_for_devices() -> void:
    if not is_client_connected():
        push_error("[BPIO] Trying to send a message on a disconnected client.")
        return
    
    _queue_message(_BPIOMessage.MessageStopScanning.new())

## Requests the server to return a list of currently connected devices.
## The list is returned asynchroniously when the client receives the
## information.
func list_devices() -> Array[BPIODevice]:
    if not is_client_connected():
        push_error("[BPIO] Trying to send a message on a disconnected client.")
        return []
    
    var msg := await _queue_message_and_await(_BPIOMessage.MessageRequestDeviceList.new())

    var arr: Array[BPIODevice] = []

    for devinfo in msg.devices:
        var dev: BPIODevice
        
        if _devices.has(devinfo.index):
            dev = _devices[devinfo.index]
        else:
            dev = _create_device(devinfo)
            _devices[devinfo.index] = dev

        arr.push_back(dev)

    @warning_ignore("standalone_expression")
    arr.sort_custom(func(a,b): a.device_index < b.device_index)

    return arr

## Requests the server to stop all actuators on all devices.
func stop_all_devices() -> void:
    if not is_client_connected():
        push_error("[BPIO] Trying to send a message on a disconnected client.")
        return
    
    _queue_message(_BPIOMessage.MessageStopAllDevices.new())



var _socket := BPIOConnection.new()

var _devices: Dictionary = {}
var _message_queue: Array[_BPIOMessage.OutboundMessage] = []



func _ready() -> void:
    _socket.connection_failed.connect(_on_socket_connection_failed)
    _socket.disconnected.connect(_on_socket_disconnected)
    _socket.message_server_info_received.connect(_on_socket_server_info_received)
    _socket.message_device_added_received.connect(_on_socket_device_added_received)
    _socket.message_device_removed_received.connect(_on_socket_device_removed_received)
    _socket.message_sensor_reading_received.connect(_on_socket_sensor_reading_received)

    set_process(false)

func _process(_dt: float) -> void:
    _socket.update_state()

    if _socket.is_socket_connected():
        _socket.poll()
    
    for device: BPIODevice in _devices.values():
        device._queue_messages_in_client()
    
    if _message_queue.size() > 0:
        _send_queued_messages()



func _on_socket_connection_failed(c: int, r: String) -> void:
    connection_failed.emit("{} ({})".format(c, r))

func _on_socket_disconnected() -> void:
    disconnected.emit()
    set_process(false)

func _on_socket_server_info_received(_m) -> void:
    connected.emit()
    set_process(true)

func _on_socket_device_added_received(msg: _BPIOMessage.MessageDeviceAdded) -> void:
    var dev := _create_device(msg)
    _devices[dev.device_index] = dev
    device_connected.emit(dev)

func _on_socket_device_removed_received(msg: _BPIOMessage.MessageDeviceRemoved) -> void:
    if not _devices.has(msg.index):
        return
    
    var dev := _devices[msg.index] as BPIODevice
    _devices.erase(msg.index)

    device_disconnected.emit(dev)
    dev.disconnected.emit()
    dev._device_index = -1

func _on_socket_scanning_finished(_msg: _BPIOMessage.MessageScanningFinished) -> void:
    scanning_finished.emit()

func _on_socket_sensor_reading_received(msg: _BPIOMessage.MessageSensorReading) -> void:
    if not _devices.has(msg.device_index):
        return
    
    var dev := _devices[msg.device_index] as BPIODevice
    dev._sensor_data[msg.sensor_index] = msg.data
    sensor_data_received.emit(dev, msg.sensor_index, msg.data)



func _queue_message(msg: _BPIOMessage.OutboundMessage) -> void:
    _message_queue.push_back(msg)

func _queue_messages(msgs: Array[_BPIOMessage.OutboundMessage]) -> void:
    for msg in msgs:
        _queue_message(msg)

func _queue_message_with_id(msg: _BPIOMessage.OutboundMessage) -> int:
    var id := _socket.increment_next_message_id()
    msg.id = id
    _queue_message(msg)
    return id

func _queue_message_and_await(msg: _BPIOMessage.OutboundMessage) -> _BPIOMessage.InboundMessage:
    var id := _queue_message_with_id(msg)
    return await _await_msg(id, msg.get_message_name())



func _await_msg(id: int, msgname: String) -> _BPIOMessage.InboundMessage:
    while true:
        var msg: _BPIOMessage.InboundMessage = await _socket.message_received

        if msg.id == id:
            if msg is _BPIOMessage.MessageError:
                push_error("[BPIO] Error received after sending a ", msgname, " message (ID ", id, "): ", msg.error_message, " (", msg.error_code, ")")
                break
            
            return msg
    
    return null



func _create_device(data) -> BPIODevice:
    var dev := BPIODevice.new()
    dev._name = data.name
    dev._device_index = data.index
    dev._message_timing_gap = data.message_timing_gap
    dev._display_name = data.display_name
    dev._messages = data.messages
    dev._client = self
    dev._last_sent_time = Time.get_ticks_msec()
    return dev



func _send_queued_messages() -> void:
    _socket.send_messages(_message_queue)
    _message_queue.clear()
