extends Node2D
class_name Level

signal enemy_died(dead_enemy:CharacterBody2D)

@onready var arrow_holder :=$ArrowHolder
@onready var enemy_holder :=$EnemyHolder
@onready var player_health_bar := $Control/HealthBar
@onready var exp_bar := $Control/ExpBar
@onready var level_label := $Control/LevelLabel

var enemy_list=[]

func _ready() -> void:
	enemy_died.connect(_on_enemy_died)
	GetEnemies()

func GetEnemies():
	enemy_list=[]
	for child in enemy_holder.get_children():
		enemy_list.append(child)


func _on_enemy_died(enemy_that_died:CharacterBody2D):
	var index = enemy_list.find(enemy_that_died)
	enemy_list.remove_at(index)
	#GetEnemies()
