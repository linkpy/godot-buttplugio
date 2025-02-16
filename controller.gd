extends MarginContainer

@onready var n_client := $%client as BPIOClient
@onready var n_connection := $%connection as UI_Connection
@onready var n_status := $%status as Label
@onready var n_device_list := $%device_list as UI_DeviceList
@onready var n_device_info := $%device_info as UI_DeviceInfo



func _on_client_connected() -> void:
    n_status.text = "Connected"

    var device_list = await n_client.list_devices()
    n_device_list.set_devices(device_list)

func _on_client_connection_failed(why: String) -> void:
    n_connection.set_disconnected()

    n_status.text = "Connection failed: " + why

func _on_client_disconnected() -> void:
    n_connection.set_disconnected()

    n_status.text = "Disconnected"

func _on_client_device_connected(device: BPIODevice) -> void:
    n_device_list.add_device(device)

func _on_client_device_disconnected(device: BPIODevice) -> void:
    n_device_list.remove_device(device)



func _on_connection_connection_requested(url: String) -> void:
    n_client.connect_to_server(url)
    n_connection.set_connected()

    n_status.text = "Connecting..."

func _on_connection_disconnect_requested() -> void:
    n_client.disconnect_from_server()

    n_device_list.reset()
    n_device_info.reset()

    n_status.text = "Disconnecting..."



func _on_device_list_device_selected(idx: int) -> void:
    if idx == -1:
        n_device_info.reset()
    
    else:
        var device := n_client.get_device(idx)
        n_device_info.set_device(device)
