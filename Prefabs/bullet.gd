extends Area2D

@export var speed: float = 600

var direction: Vector2 = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position+= direction * speed * delta
