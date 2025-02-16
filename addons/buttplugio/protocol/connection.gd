## WebSocket wrapper, handling the connection and message encoding/decoding 
## for a Buttplug.IO compatible server.
##
## This class implement support for the Buttplug Intimate Device Control 
## Standard, version 3. For more information about the underlying protocol,
## please see the [url=https://buttplug-spec.docs.buttplug.io/docs/spec/]specifications[/url].
## [br][br]
## [b]Note[/b]: It is recommanded to use the [BPIOClient] class, which is a 
## higher-level API around the Buttplug.IO protocol. 
##
class_name BPIOConnection extends RefCounted


## Protocol version of the connection.
const MESSAGE_VERSION := 3

const _Messages = preload("res://addons/buttplugio/protocol/message.gd")


## A connection to the WebSocket server [param url] have been requested to the 
## socket.
signal connection_requested(url: String)
## A disconnection from the server have been requested to the socket.
signal disconnected_requested()
## The connection was established to a server. [br][br]
##
## [b]Note[/b]: This signal is emitted *before* having received server metadata.
## If server information is necessary, you should wait on 
## [signal message_server_info_received] after a conneciton 
## has been established.
##
signal connected()
## The connection is now fully closed. 
signal disconnected()
## The connection attempt to a server failed, because of the [param code] and
## [param reason]. Both of these are the underlying WebSocket's close code and
## reason. For more information, see [method WebSocketPeer.close]. [br][br]
## 
## [b]Note[/b]: [param code] and [param reason] can also be from [enum Error] if Godot
## failed to initiate the connection to the server.
signal connection_failed(code: int, reason: String)


## A message have been received from the server.
signal message_received(msg: _Messages.InboundMessage)
## An "Ok" message have been received from the server.
signal message_ok_received(msg: _Messages.MessageOk)
## An "Error" message have been received from the server.
signal message_error_received(msg: _Messages.MessageError)
## A "ServerInfo" message have been received from the server.
signal message_server_info_received(msg: _Messages.MessageServerInfo)
## A "ScanningFinished" message have been received from the server.
signal message_scanning_finished_received(msg: _Messages.MessageScanningFinished)
## A "DeviceList" message have been received from the server.
signal message_device_list_received(msg: _Messages.MessageDeviceList)
## A "DeviceAdded" message have been received from the server. 
signal message_device_added_received(msg: _Messages.MessageDeviceAdded)
## A "DeviceRemoved" message have been received from the server.
signal message_device_removed_received(msg: _Messages.MessageDeviceRemoved)
## A "SensorReading" message have been received from the server.
signal message_sensor_reading_received(msg: _Messages.MessageSensorReading)


## Name of the client to report to the server during handshake.
var client_name: String = "Godot.SEX"


## Checks if the socket is connecting to a server.
func is_socket_connecting() -> bool:
    return _ws.get_ready_state() == WebSocketPeer.STATE_CONNECTING

## Checks if the socket is connected to a server.
func is_socket_connected() -> bool:
    return _ws.get_ready_state() == WebSocketPeer.STATE_OPEN

## Checks if the server is disconnected from a server.
func is_socket_disconnected() -> bool:
    return _ws.get_ready_state() == WebSocketPeer.STATE_CLOSED

## Checks if the server is disconnecting from a server.
func is_socket_disconnecting() -> bool:
    return _ws.get_ready_state() == WebSocketPeer.STATE_CLOSING



## Gets the ID of the next outgoing message.
func get_next_message_id() -> int:
    return _msg_id

## Increments the ID of the next outgoing message. 
## Returns the previous ID.
func increment_next_message_id() -> int:
    _msg_id += 1
    return _msg_id - 1


## Connects the socket to the server [param url]. Returns [code]true[/code]
## if the connection was succesfully initiated.
func connect_socket(url: String) -> bool:
    if not is_socket_disconnected():
        push_error("[BPIO] Trying to connect to an already connected socket.")
        return false
    
    print("[BPIO] Connecting to server ", url, "...")
    connection_requested.emit(url)

    var err := _ws.connect_to_url(url)
    if err != OK:
        print("[BPIO] Failed to connect to server: ", error_string(err))
        connection_failed.emit(err, error_string(err))
        return false
    
    _msg_id = 1
    _last_ping_time = Time.get_ticks_msec()
    _max_ping_time = 0

    return true

## Disconnects the socket from the currently connected server.
func disconnect_socket() -> void:
    if not is_socket_connected():
        push_error("[BPIO] Trying to disconnected a non-connected socket.")
        return
    
    _ws.close()

    print("[BPIO] Disconnecting...")
    disconnected_requested.emit()



## Updates the socket state. Should be call frequently (ie [method Node._process]), unless
## the socket is fully disconnected (see [method is_socket_disconnected]).
func update_state() -> void:
    var curr := _ws.get_ready_state()
    var last := _ws_last_state

    _ws_last_state = curr

    match last:
        WebSocketPeer.STATE_CONNECTING:
            match curr:
                WebSocketPeer.STATE_CONNECTING:
                    _ws.poll() # needed to fullfil the connection
                WebSocketPeer.STATE_OPEN:
                    print("[BPIO] Connection to server successful.")
                    _send_request_server_info()
                    connected.emit()
                WebSocketPeer.STATE_CLOSING:
                    print("[BPIO] Weird state: CONNECTING -> CLOSING")
                WebSocketPeer.STATE_CLOSED:
                    var code := _ws.get_close_code()
                    var reason := _ws.get_close_reason()
                    print("[BPIO] Failed to connect to server: ", code, " ", reason)
                    connection_failed.emit(code, reason)
        WebSocketPeer.STATE_OPEN:
            match curr:
                WebSocketPeer.STATE_CONNECTING: 
                    print("[BPIO] Weird state: OPEN -> CONNECTING")
                WebSocketPeer.STATE_CLOSED: 
                    print("[BPIO] Weird state: OPEN -> CLOSED")
        WebSocketPeer.STATE_CLOSING:
            match curr:
                WebSocketPeer.STATE_CLOSING:
                    _ws.poll() # needed to fullfil the disconnection
                WebSocketPeer.STATE_CLOSED:
                    print("[BPIO] Disconnected from server.")
                    disconnected.emit()
                WebSocketPeer.STATE_CONNECTING:
                    print("[BPIO] Weird state: CLOSING -> CONNECTING")
                WebSocketPeer.STATE_OPEN:
                    print("[BPIO] Weird state: CLOSING -> OPEN")
        WebSocketPeer.STATE_CLOSED: 
            match curr:
                WebSocketPeer.STATE_OPEN:
                    print("[BPIO] Weird state: CLOSED -> OPEN")
                WebSocketPeer.STATE_CLOSING:
                    print("[BPIO] Weird state: CLOSED -> CLOSING")

## Polls packets from the socket and parse them into messages, 
## dispatching them through [signal message_received] and associated
## signals. Should be called frequently (ie [method Node._process]) 
## when the socket is open (see [method is_socket_connected]).
func poll() -> void:
    if not is_socket_connected():
        push_error("[BPIO] Trying to poll a non-connected BPIO connection.")
        return
    
    _ws.poll()

    _parse_packets()
    _send_ping_if_necessary()


## Sends the message [param msg] immediately.
func send_message(msg: _Messages.OutboundMessage) -> void:
    send_messages([msg])

## Sends the messages [param msgs] immediately.
func send_messages(msgs: Array[_Messages.OutboundMessage]) -> void:
    for msg in msgs:
        if msg.id == 0:
            msg.id = _msg_id
            _msg_id += 1
        else:
            _msg_id = max(_msg_id, msg.id) + 1

    var as_dicts = msgs.map(func(x): return x.to_dict())
    var json := JSON.stringify(as_dicts)
    _ws.send_text(json)




var _ws: WebSocketPeer = WebSocketPeer.new()
var _ws_last_state: int = 0

var _msg_id: int = 1

var _last_ping_time: int = 0
var _max_ping_time: int = 0

var _server_name: String = ""
var _message_version: int = 0



func _parse_packets() -> void:
    while _ws.get_available_packet_count() > 0:
        var packet := _ws.get_packet().get_string_from_utf8()
        var data = JSON.parse_string(packet)

        if data == null:
            push_error("[BPIO] Invalid JSON packet received from the server.")
            continue
        
        var messages := data as Array

        for message in messages:
            var content := message as Dictionary

            if content == null:
                push_error("[BPIO] Invalid JSON object in packet.")
                continue
            
            var instance := _Messages.InboundMessage.from_dict(content)

            if instance == null:
                # error already printed by from_dict
                continue

            _dispatch_message(instance)

func _dispatch_message(msg: _Messages.InboundMessage) -> void:
    message_received.emit(msg)

    if msg is _Messages.MessageOk:
        message_ok_received.emit(msg)
    elif msg is _Messages.MessageError:
        message_error_received.emit(msg)
    elif msg is _Messages.MessageServerInfo:
        _retreive_server_info(msg)
        message_server_info_received.emit(msg)
    elif msg is _Messages.MessageScanningFinished:
        message_scanning_finished_received.emit(msg)
    elif msg is _Messages.MessageDeviceList:
        message_device_list_received.emit(msg)
    elif msg is _Messages.MessageDeviceAdded:
        message_device_added_received.emit(msg)
    elif msg is _Messages.MessageDeviceRemoved:
        message_device_removed_received.emit(msg)    
    elif msg is _Messages.MessageSensorReading:
        message_sensor_reading_received.emit(msg)



func _send_request_server_info() -> void:
    var msg := _Messages.MessageRequestServerInfo.new()
    msg.client_name = client_name
    msg.message_version = MESSAGE_VERSION
    send_message(msg)

func _retreive_server_info(msg: _Messages.MessageServerInfo) -> void:
    _server_name = msg.server_name
    _message_version = msg.message_version
    _max_ping_time = msg.max_ping_time

    if _message_version < MESSAGE_VERSION:
        push_warning("[BPIO] Server message version is not up to date. Except errors.")



func _send_ping_if_necessary() -> void:
    if _max_ping_time <= 0:
        return
    
    var curr := Time.get_ticks_msec()
    var last := _last_ping_time

    @warning_ignore("integer_division")
    if (curr - last) < (_max_ping_time / 2):
        return
    
    send_message(_Messages.MessagePing.new())
    _last_ping_time = curr
