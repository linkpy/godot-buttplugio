extends Control


@onready var client: BPIOClient = $client

func _ready() -> void:
    test_lib()

func test_lib() -> void:
    client.connect_to_server()
    await client.connected

    var devices := await client.list_devices()

    for dev in devices:
        if dev.get_vibrator_count() > 0:
            dev.vibrate(-1, 0.1)
    
    await get_tree().create_timer(2).timeout

    client.stop_all_devices()
