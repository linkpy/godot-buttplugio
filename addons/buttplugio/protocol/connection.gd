class_name BPIOConnection extends RefCounted

const BPIOMessage = preload("res://addons/buttplugio/protocol/message.gd")
const MESSAGE_VERSION := 3

signal connection_requested(url: String)
signal disconnected_requested()
signal connected()
signal disconnected()
signal connection_failed(code: int, reason: String)

signal message_received(msg: BPIOMessage.InboundMessage)
signal message_ok_received(msg: BPIOMessage.MessageOk)
signal message_error_received(msg: BPIOMessage.MessageError)
signal message_server_info_received(msg: BPIOMessage.MessageServerInfo)
signal message_scanning_finished_received(msg: BPIOMessage.MessageScanningFinished)
signal message_device_list_received(msg: BPIOMessage.MessageDeviceList)
signal message_device_added_received(msg: BPIOMessage.MessageDeviceAdded)
signal message_device_removed_received(msg: BPIOMessage.MessageDeviceRemoved)
signal message_sensor_reading_received(msg: BPIOMessage.MessageSensorReading)



var client_name: String = "Godot.SEX"



var _ws: WebSocketPeer = WebSocketPeer.new()
var _ws_last_state: int = 0

var _msg_id: int = 1

var _last_ping_time: int = 0
var _max_ping_time: int = 0

var _server_name: String = ""
var _message_version: int = 0



func is_socket_connecting() -> bool:
    return _ws.get_ready_state() == WebSocketPeer.STATE_CONNECTING

func is_socket_connected() -> bool:
    return _ws.get_ready_state() == WebSocketPeer.STATE_OPEN

func is_socket_disconnected() -> bool:
    return _ws.get_ready_state() == WebSocketPeer.STATE_CLOSED

func is_socket_disconnecting() -> bool:
    return _ws.get_ready_state() == WebSocketPeer.STATE_CLOSING



func get_next_message_id() -> int:
    return _msg_id

func increment_next_message_id() -> int:
    _msg_id += 1
    return _msg_id - 1



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

func disconnect_socket() -> void:
    if not is_socket_connected():
        push_error("[BPIO] Trying to disconnected a non-connected socket.")
        return
    
    _ws.close()

    print("[BPIO] Disconnecting...")
    disconnected_requested.emit()



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

func poll() -> void:
    if not is_socket_connected():
        push_error("[BPIO] Trying to poll a non-connected BPIO connection.")
        return
    
    _ws.poll()

    _parse_packets()
    _send_ping_if_necessary()



func send_message(msg: BPIOMessage.OutboundMessage) -> void:
    send_messages([msg])

func send_messages(msgs: Array[BPIOMessage.OutboundMessage]) -> void:
    for msg in msgs:
        if msg.id == 0:
            msg.id = _msg_id
            _msg_id += 1
        else:
            _msg_id = max(_msg_id, msg.id) + 1

    var as_dicts = msgs.map(func(x): return x.to_dict())
    var json := JSON.stringify(as_dicts)
    _ws.send_text(json)



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
            
            var instance := BPIOMessage.InboundMessage.from_dict(content)

            if instance == null:
                # error already printed by from_dict
                continue

            _dispatch_message(instance)

func _dispatch_message(msg: BPIOMessage.InboundMessage) -> void:
    message_received.emit(msg)

    if msg is BPIOMessage.MessageOk:
        message_ok_received.emit(msg)
    elif msg is BPIOMessage.MessageError:
        message_error_received.emit(msg)
    elif msg is BPIOMessage.MessageServerInfo:
        _retreive_server_info(msg)
        message_server_info_received.emit(msg)
    elif msg is BPIOMessage.MessageScanningFinished:
        message_scanning_finished_received.emit(msg)
    elif msg is BPIOMessage.MessageDeviceList:
        message_device_list_received.emit(msg)
    elif msg is BPIOMessage.MessageDeviceAdded:
        message_device_added_received.emit(msg)
    elif msg is BPIOMessage.MessageDeviceRemoved:
        message_device_removed_received.emit(msg)    
    elif msg is BPIOMessage.MessageSensorReading:
        message_sensor_reading_received.emit(msg)



func _send_request_server_info() -> void:
    var msg := BPIOMessage.MessageRequestServerInfo.new()
    msg.client_name = client_name
    msg.message_version = MESSAGE_VERSION
    send_message(msg)

func _retreive_server_info(msg: BPIOMessage.MessageServerInfo) -> void:
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
    
    send_message(BPIOMessage.MessagePing.new())
    _last_ping_time = curr
