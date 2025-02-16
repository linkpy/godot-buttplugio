class_name UI_FeatureEntry extends MarginContainer


var _device: BPIODevice
var _kind: int = VIBRATOR
var _index: int = 0



func set_feature(dev: BPIODevice, kind: int, idx: int) -> void:
	_device = dev
	_kind = kind
	_index = idx

	match kind:
		VIBRATOR:
			$%step_count_label.visible = true
			$%step_count.visible = true
			$%actuator_type_label.visible = true
			$%actuator_type.visible = true
			$%scalar_controls.visible = true

			$%kind.text = "Vibrator"
			$%descriptor.text = dev.get_vibrator_descriptor(idx)
			$%step_count.text = str(dev.get_vibrator_step_count(idx))
			$%actuator_type.text = dev.get_vibrator_type(idx)

			$%scalar_slider.tick_count = dev.get_vibrator_step_count(idx) + 1
			$%scalar_slider.step = floor(100.0 / dev.get_vibrator_step_count(idx))
			$%scalar_value.step = $%scalar_slider.step
		TRANSLATOR:
			$%step_count_label.visible = true
			$%step_count.visible = true
			$%actuator_type_label.visible = true
			$%actuator_type.visible = true
			$%linear_controls.visible = true

			$%kind.text = "Translator"
			$%descriptor.text = dev.get_translator_descriptor(idx)
			$%step_count.text = str(dev.get_translator_step_count(idx))
			$%actuator_type.text = dev.get_translator_type(idx)

			$%vector_position.tick_count = dev.get_vibrator_step_count(idx) + 1
			$%vector_position.step = floor(100.0 / dev.get_vibrator_step_count(idx))
		ROTATOR:
			$%step_count_label.visible = true
			$%step_count.visible = true
			$%actuator_type_label.visible = true
			$%actuator_type.visible = true
			$%rotation_controls.visible = true

			$%kind.text = "Rotator"
			$%descriptor.text = dev.get_rotator_descriptor(idx)
			$%step_count.text = str(dev.get_rotator_step_count(idx))
			$%actuator_type.text = dev.get_rotator_type(idx)

			$%rotation_speed.tick_count = dev.get_vibrator_step_count(idx) + 1
			$%rotation_speed.step = floor(100.0 / dev.get_vibrator_step_count(idx))
		SENSOR:
			$%sensor_type_label.visible = true
			$%sensor_type.visible = true
			$%sensor_range_label.visible = true
			$%sensor_range.visible = true
			$%sensor_controls.visible = true

			$%kind.text = "Sensor"
			$%descriptor.text = dev.get_sensor_descriptor(idx)
			$%sensor_type.text = dev.get_sensor_type(idx)
			$%sensor_range.text = str(dev.get_sensor_range(idx))



enum {
	VIBRATOR, 
	TRANSLATOR, 
	ROTATOR, 
	SENSOR
}



func _on_scalar_slider_value_changed(value: float) -> void:
	$%scalar_value.set_value_no_signal(value)
	_device.vibrate(_index, clamp(value / 100.0, 0.0, 1.0))

func _on_scalar_value_value_changed(value: float) -> void:
	$%scalar_slider.set_value_no_signal(value)
	_device.vibrate(_index, clamp(value / 100.0, 0.0, 1.0))



func _on_vector_position_value_changed(value: float) -> void:
	_device.translate(_index, $%vector_duration.value, clamp(value / 100.0, 0 ,1))

func _on_vector_duration_value_changed(value: float) -> void:
	_device.translate(_index, value, clamp($%vector_position.value / 100.0, 0, 1))



func _on_rotation_speed_value_changed(value: float) -> void:
	_device.rotate(_index, clamp(value / 100.0, 0, 1), $%rotation_clockwise.button_pressed)

func _on_rotation_clockwise_toggled(toggled_on: bool) -> void:
	_device.rotate(_index, clamp($%rotation_speed.value / 100.0, 0, 1), toggled_on)



func _on_sensor_read_pressed() -> void:
	var data = await _device.read_sensor(_index)
	print(data)
	$%sensor_data.text = str(data)
