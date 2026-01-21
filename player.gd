extends CharacterBody2D
class_name Player

@onready var idle_sheet:= load("res://Assets/Units/Blue Units/Archer/Archer_Idle.png")
@onready var attack_sheet:= load("res://Assets/Units/Blue Units/Archer/Archer_Shoot.png")
@onready var run_sheet:= load("res://Assets/Units/Blue Units/Archer/Archer_Run.png")

@onready var player_sprite:=$Sprite2D
@onready var anim_player:=$AnimationPlayer
@onready var attack_timer :=$AttackTimer


var direction: Vector2
var facing_right: bool = true
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var arrow_scene_string : String
var arrow_scene : Resource
var current_scene :Level

@export var can_attack:= true

#base stats
var base_attack : float = 1.0
var current_attack:float
var base_hp : float =10.0
var current_hp:float
var max_hp :float
var target_exp:float
var current_exp:float = 0
var player_level:int = 1



func _ready() -> void:
	arrow_scene = load(arrow_scene_string)
	current_scene = get_tree().get_first_node_in_group("MainScene")
	await current_scene.ready
	SetStats()


func _process(delta: float) -> void:
	direction=Vector2.ZERO
	if(Input.is_action_pressed("ui_up")):
		direction.y += -1
	if(Input.is_action_pressed("ui_down")):
		direction.y += 1
	if(Input.is_action_pressed("ui_left")):
		direction.x += -1
		#player_sprite.set_flip_h(true)		
	if(Input.is_action_pressed("ui_right")):
		direction.x += 1
		#player_sprite.set_flip_h(false)
	#if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		#Attack()
	direction=direction.normalized()
	

func _physics_process(delta: float) -> void:
	
	velocity=direction  * SPEED
	AnimatePlayer()
	move_and_slide()
	
func AnimatePlayer():
	if direction==Vector2.ZERO:
		if can_attack and current_scene.enemy_list.size()>0:
			player_sprite.texture=attack_sheet
			anim_player.play("attack")
		else:
			player_sprite.texture = idle_sheet
			anim_player.play("idle")
	else:
		if direction.x>=0:
			facing_right = true
		else:
			facing_right = false
		player_sprite.texture = run_sheet
		anim_player.play("run")
	player_sprite.flip_h = !facing_right

func Attack():
	print("Shot arrow!")
	#can_attack = false
	#attack_timer.start()
	var new_arrow: Arrow = arrow_scene.instantiate()
	var closes_distance:=5000
	var target_enemy
	for enemy in current_scene.enemy_list:
		if enemy.position.distance_to(position)<closes_distance:
			closes_distance=enemy.position.distance_to(position)
			target_enemy = enemy
	new_arrow.target = target_enemy
	new_arrow.position = position
	new_arrow.damage = current_attack
	current_scene.arrow_holder.add_child(new_arrow)

func SetStats():
	current_attack= base_attack
	max_hp = base_hp
	current_hp  =max_hp
	target_exp = player_level*2
	UpdateUI()
	
func UpdateUI(): #focar a cena de lv a atualizar UI
	current_scene.player_health_bar.max_value=max_hp	
	current_scene.player_health_bar.value = current_hp
	current_scene.exp_bar.max_value = target_exp
	current_scene.exp_bar.value = current_exp
	current_scene.level_label.text ="LEVEL: "+str(player_level)
	

func _on_attack_timer_timeout() -> void:
	can_attack=true
