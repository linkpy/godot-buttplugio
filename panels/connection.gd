class_name UI_Connection extends PanelContainer



signal connection_requested(url: String)
signal disconnect_requested()



@onready var n_url := $%url_input as LineEdit
@onready var n_connect := $%connect_btn as Button
@onready var n_disconnect := $%disconnect_btn as Button



func set_connected() -> void:
    n_url.editable = false
    n_connect.disabled = true
    n_disconnect.disabled = false

func set_disconnected() -> void:
    n_url.editable = true
    n_connect.disabled = false
    n_disconnect.disabled = true



func _on_connect_btn_pressed() -> void:
    connection_requested.emit(n_url.text)

func _on_disconnect_btn_pressed() -> void:
    disconnect_requested.emit()
