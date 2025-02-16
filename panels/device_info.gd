class_name UI_DeviceInfo extends ScrollContainer


@onready var n_device_meta := $%device_metadata as UI_DeviceMetadata
@onready var n_features := $%features as UI_Features



func set_device(dev: BPIODevice) -> void:
    n_device_meta.set_device(dev)
    n_features.set_device(dev)



func reset() -> void:
    n_device_meta.reset()
    n_features.reset()
