extends Area2D

@export var speed := 500.0
#@export var max_time := 3.0

var direction: Vector2
#var target: Node = null

@onready var life_timer = $LifeTimer

#func _ready():
	#life_timer.wait_time = max_time
	#life_timer.start()

func _process(delta):
	var angle = direction.angle()
	rotation = angle
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("Enemies"):
		body.start_simbio_mark()
		queue_free()
		#target = body
		#life_timer.stop()

func _on_life_timer_timeout() -> void:
	queue_free()
	
