class_name UI_DeviceMetadata extends PanelContainer


@onready var n_name := $%name_value as LineEdit
@onready var n_display_name := $%display_name_value as LineEdit
@onready var n_device_index := $%device_index_value as LineEdit
@onready var n_scalar := $%scalar_value as LineEdit
@onready var n_linear := $%linear_value as LineEdit
@onready var n_rotation := $%rotation_value as LineEdit
@onready var n_sensors := $%sensors_value as LineEdit



func set_device(dev: BPIODevice) -> void:
	n_name.text = dev.name
	n_display_name.text = dev.display_name
	n_device_index.text = str(dev.device_index)
	n_scalar.text = str(dev.get_vibrator_count())
	n_linear.text = str(dev.get_translator_count())
	n_rotation.text = str(dev.get_rotator_count())
	n_sensors.text = str(dev.get_sensor_count())

func reset() -> void:
	n_name.text = ""
	n_display_name.text = ""
	n_device_index.text = ""
	n_scalar.text = ""
	n_linear.text = ""
	n_rotation.text = ""
	n_sensors.text = ""
