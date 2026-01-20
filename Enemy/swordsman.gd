extends CharacterBody2D
class_name Swordsman

@onready var nav_agent := $NavigationAgent2D
@onready var anim_player:= $AnimationPlayer

@onready var current_sprite := $Sprite2D
@onready var idle_sheet:= load("res://Assets/Units/Red Units/Warrior/Warrior_Idle.png")
@onready var attack_sheet:= load("res://Assets/Units/Red Units/Warrior/Warrior_Attack1.png")
@onready var run_sheet:= load("res://Assets/Units/Red Units/Warrior/Warrior_Run.png")

var player_ref : Player
var current_state : STATE
const SPEED:= 190
enum STATE{
	RUN,
	ATTACK,
	IDLE
}

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("Player")
	anim_player.play("run")
	
func _physics_process(delta: float) -> void:
	if current_state == STATE.RUN:
		nav_agent.target_position = player_ref.position
		velocity = position.direction_to(nav_agent.get_next_path_position()) * SPEED
		#anim_player.play("idle")
		move_and_slide()
	
func ChangeState(new_state:STATE):
	if(new_state==STATE.RUN):
		current_sprite.texture = run_sheet
		#anim_player.play("run")
	elif(new_state==STATE.ATTACK):
		current_sprite.texture = attack_sheet
		#anim_player.play("attack")
	else: #(new_state==STATE.IDLE):
		current_sprite.texture = idle_sheet
		#anim_player.play("idle")
	current_state = new_state


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		anim_player.play("attack")


func _on_timer_timeout() -> void:
	#current_state = STATE.RUN
	anim_player.play("run")
