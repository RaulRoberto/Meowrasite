extends CharacterBody2D

@onready var nav_agent := $NavigationAgent2D
var player_ref : Player
const SPEED:= 190

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("Player")
	
func _physics_process(delta: float) -> void:
	nav_agent.target_position = player_ref.position
	velocity = position.direction_to(nav_agent.get_next_path_position()) * SPEED
	move_and_slide()
