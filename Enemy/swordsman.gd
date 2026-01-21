extends CharacterBody2D
class_name Swordsman

@onready var nav_agent := $NavigationAgent2D
@onready var anim_player:= $AnimationPlayer
@onready var health_bar := $ProgressBar
#@onready var character:= $Vector2
@onready var current_sprite := $Sprite2D
@onready var idle_sheet:= load("res://Assets/Units/Red Units/Warrior/Warrior_Idle.png")
@onready var attack_sheet:= load("res://Assets/Units/Red Units/Warrior/Warrior_Attack1.png")
@onready var run_sheet:= load("res://Assets/Units/Red Units/Warrior/Warrior_Run.png")

var current_scene

var player_in_range := false
var player_ref : Player
var current_state : STATE
const SPEED:= 190
enum STATE{
	RUN,
	ATTACK,
	IDLE
}
var base_hp := 3
var max_hp : int
var current_hp : int

var can_attack:=true
var is_simbio := false
var simbio_timer := 0.0

@export var simbio_duration := 4.0
@export var simbio_window := 3.0
@onready var timer = $SimbioTimer
@onready var timer_label = $MarkerUI/TimerLabel

var is_marked:=false


func _ready() -> void:
	current_scene = get_tree().get_first_node_in_group("MainScene")
	SetStats(1) #isso sera implementado em outro momento no mapa principal
	player_ref = get_tree().get_first_node_in_group("Player")
	anim_player.play("run")

func _process(delta):
	if is_marked:
		timer_label.text = str(ceil(timer.time_left))

func _physics_process(delta: float) -> void:
	if current_state == STATE.RUN and player_ref.visible==true:
		nav_agent.target_position = player_ref.position
		velocity = position.direction_to(nav_agent.get_next_path_position()) * SPEED
		
		#anim_player.play("idle")
		move_and_slide()
	if is_simbio:
		simbio_timer-=delta
		handle_player_input(delta)
		
		
		if simbio_timer <=0:
			end_simbio()



	
func handle_player_input(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	velocity = input_vector * 200
	move_and_slide()
	
func end_simbio():
	is_simbio=false
	set_physics_process(false)
	queue_free()
	player_ref.global_position = global_position
	player_ref.visible = true
	player_ref.set_physics_process(true)

func start_simbio_mark():
	if is_marked:
		return
	is_marked = true
	# Feedback visual (placeholder)
	current_sprite.modulate = Color(0.6, 0.3, 1.0) # roxo
	timer.wait_time = simbio_window
	timer.start()

	timer_label.visible = true
	get_tree().get_first_node_in_group("Player").marked_enemy = self

	
func start_simbio(player_ref):
	is_simbio  =true
	can_attack=false
	simbio_timer = simbio_duration
	set_physics_process(true)
		
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


func SetStats(level_num :int):
	max_hp =  base_hp * level_num
	current_hp= max_hp
	health_bar.max_value = max_hp
	health_bar.value=current_hp
	can_attack=true
	
func UpdateUI():
	health_bar.value=current_hp

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):	
		player_in_range = true
		if current_state==STATE.RUN:
			anim_player.play("attack")


func _on_timer_timeout() -> void:
	#current_state = STATE.RUN
	if player_in_range and can_attack:
		anim_player.play("attack")
	else:
		anim_player.play("run")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range=false


func _on_hurt_box_body_entered(body: Node2D) -> void:
	current_hp-=body.damage
	if current_hp<=0:
		current_scene.enemy_died.emit(self)
		#current_scene.emit_signal("enemy_died")
		queue_free()
	else:
		health_bar.value = current_hp
	body._on_hit_enemy()

func clear_simbio_mark():
	is_marked = false
	current_sprite.modulate = Color.WHITE
	timer_label.visible = false
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.marked_enemy = null
	player.start_simbio_cooldown()
	
func _on_simbio_timer_timeout() -> void:
	clear_simbio_mark()
