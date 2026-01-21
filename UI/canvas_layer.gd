extends CanvasLayer

@onready var icon = $SimbioIcon
@onready var cooldown_label = $SimbioCD

func update_simbio_ui(active: bool, time_left := 0.0, cooldown := 0.0):
	if cooldown > 0:
		icon.modulate = Color(0.3, 0.3, 0.3)
		cooldown_label.text = str(ceil(cooldown))
	elif active:
		icon.modulate = Color.WHITE
		cooldown_label.text = str(ceil(time_left))
	else:
		icon.modulate = Color.WHITE
		cooldown_label.text = ""
