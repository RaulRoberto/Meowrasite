extends CharacterBody2D
class_name Arrow

var target: CharacterBody2D
var target_coords: Vector2
var flight_speed:= 350
var direction : Vector2
var damage: float

func _ready() -> void:
	target_coords = target.position
	direction =position.direction_to(target_coords)
	
func _physics_process(delta: float) -> void:
	
	velocity=direction*flight_speed
	var angle = direction.angle()
	rotation = angle
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("Doodad"):
			queue_free()
	


func _on_despawn_timer_timeout() -> void:
	queue_free()
	
func _on_hit_enemy():
	queue_free()
