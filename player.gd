extends CharacterBody2D
class_name Player

@onready var idle_sheet:= load("res://Assets/Units/Blue Units/Archer/Archer_Idle.png")
@onready var attack_sheet:= load("res://Assets/Units/Blue Units/Archer/Archer_Shoot.png")
@onready var run_sheet:= load("res://Assets/Units/Blue Units/Archer/Archer_Run.png")

@onready var player_sprite:=$Sprite2D
@onready var anim_player:=$AnimationPlayer
@onready var attack_timer :=$AttackTimer
@onready var aim_arrow:= $AimArrow
@onready var muzzle:= $Muzzle
@onready var ui = $CanvasLayer



var direction: Vector2
var facing_right: bool = true
const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

@export var arrow_scene_string : String
@export var skill_scene: PackedScene
@export var simbio_cooldown := 8.0
var simbio_on_cooldown := false
var simbio_cooldown_time := 0.0
#var skill_scene: Resource
var arrow_scene : Resource
var current_scene :Level

@export var can_attack:= true

var simbio_bullet: Node = null
var can_simbio := false
var marked_enemy: Node = null


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
	#skill_scene = load(skill_scene_string)
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
	look_at_mouse()
	direction=direction.normalized()
	update_simbio_cooldown(delta)
	if simbio_on_cooldown:
		ui.update_simbio_ui(false, 0, simbio_cooldown_time)
	elif marked_enemy and marked_enemy.is_marked:
		ui.update_simbio_ui(true, marked_enemy.timer.time_left)
	else:
		ui.update_simbio_ui(false)

func update_simbio_cooldown(delta):
	if not simbio_on_cooldown:
		return
	simbio_cooldown_time -= delta
	if simbio_cooldown_time <= 0:
		simbio_on_cooldown = false
		
		
func _input(event):
	if event.is_action_pressed("simbio"):
		handle_simbio_input()
		
func try_simbio():
	if marked_enemy == null:
		return
	
	if not marked_enemy.is_marked:
		return
	simbio(marked_enemy)
	
	
func look_at_mouse():
	var mouse_pos = get_global_mouse_position()
	var direction= mouse_pos - global_position
	aim_arrow.rotation=direction.angle()+PI/2
	#aim_arrow.look_at(get_global_mouse_position())
	

func _physics_process(delta: float) -> void:
	
	velocity=direction  * SPEED
	AnimatePlayer()
	move_and_slide()
#	current_scene.enemy_list.size()>0:
func AnimatePlayer():
	if direction==Vector2.ZERO:
		if can_attack and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			player_sprite.texture=attack_sheet
			anim_player.play("attack")
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			shoot_simbio_skill()
			reactive_simbio()
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
	new_arrow.global_position = muzzle.global_position	
	var mouse_pos = get_global_mouse_position()
	new_arrow.direction = (mouse_pos  - global_position).normalized()
	new_arrow.position = position
	new_arrow.damage = current_attack
	current_scene.arrow_holder.add_child(new_arrow)

func handle_simbio_input():
	#if marked_enemy != null and marked_enemy.is_marked:
		#try_simbio()
	if simbio_on_cooldown:
		return
	if can_reactivate_simbio():
		reactive_simbio()
	else:
		shoot_simbio_skill()

func can_reactivate_simbio() -> bool:
	return marked_enemy != null and marked_enemy.is_marked

func shoot_simbio_skill():
	if marked_enemy!=null:
		return
	simbio_bullet = skill_scene.instantiate()
	simbio_bullet.global_position = muzzle.global_position
	simbio_bullet.direction = (get_global_mouse_position()-global_position).normalized()
	
	#simbio_bullet.connect("tree_exited",Callable(self,"_on_simbio_expired"))
	get_tree().current_scene.add_child(simbio_bullet)
	
func reactive_simbio():
	if marked_enemy == null:
		return
	if not marked_enemy.is_marked:
		marked_enemy = null
		return
	print("REACTIVATE PRESSED")
	simbio(marked_enemy)

func simbio(enemy):
	enemy.clear_simbio_mark()
	visible = false
	set_physics_process(false)
	
	enemy.start_simbio(self)
	marked_enemy=null
	
	#simbio_bullet.queue_free()
	#simbio_bullet = null
	
func start_simbio_cooldown():
	simbio_on_cooldown = true
	simbio_cooldown_time = simbio_cooldown
	
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
	
func _on_bullet_expired():
	simbio_bullet = null
	
func _on_attack_timer_timeout() -> void:
	can_attack=true
