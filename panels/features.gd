class_name UI_Features extends PanelContainer


const FeatureEntry = preload("res://panels/feature_entry.tscn")



@onready var n_none := $%none as Label



var _features: Array[UI_FeatureEntry] = []



func set_device(dev: BPIODevice) -> void:
    if not _features.is_empty():
        for x in _features:
            x.queue_free()
        _features.clear()
        n_none.show()

    var count := dev.get_vibrator_count()
    count += dev.get_translator_count()
    count += dev.get_rotator_count()
    count += dev.get_sensor_count()

    if count > 0:
        n_none.hide()

    for i in range(dev.get_vibrator_count()):
        var entry = FeatureEntry.instantiate()
        $vb.add_child(entry)

        entry.set_feature(dev, UI_FeatureEntry.VIBRATOR, i)
        _features.push_back(entry)
    
    for i in range(dev.get_translator_count()):
        var entry = FeatureEntry.instantiate()
        $vb.add_child(entry)

        entry.set_feature(dev, UI_FeatureEntry.TRANSLATOR, i)
        _features.push_back(entry)
    
    for i in range(dev.get_rotator_count()):
        var entry = FeatureEntry.instantiate()
        $vb.add_child(entry)

        entry.set_feature(dev, UI_FeatureEntry.ROTATOR, i)
        _features.push_back(entry)
    
    for i in range(dev.get_sensor_count()):
        var entry = FeatureEntry.instantiate()
        $vb.add_child(entry)

        entry.set_feature(dev, UI_FeatureEntry.SENSOR, i)
        _features.push_back(entry)

func reset() -> void:
    for feature in _features:
        feature.queue_free()
    
    _features.clear()
    n_none.show()