class_name UI_DeviceList extends VBoxContainer

signal device_selected(idx: int)



@onready var n_devices := $%devices as ItemList

var _item_map: Dictionary = {}



func set_devices(devices: Array[BPIODevice]) -> void:
    reset()

    for device in devices:
        add_device(device)

func add_device(device: BPIODevice) -> void:
    var itemname := "{0} ({1})".format([device.name, device.device_index])
    var item := n_devices.add_item(itemname)
    n_devices.set_item_metadata(item, device.device_index)
    _item_map[device.device_index] = item

func remove_device(device: BPIODevice) -> void:
    var item := _item_map[device.device_index] as int

    if n_devices.is_anything_selected() and n_devices.get_selected_items()[0] == item:
        device_selected.emit(-1)

    n_devices.remove_item(item)
    _item_map.erase(device.device_index)



func reset() -> void:
    n_devices.clear()
    _item_map.clear()



func _on_devices_item_selected(index: int) -> void:
    var dev := n_devices.get_item_metadata(index) as int
    device_selected.emit(dev)
