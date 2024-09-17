extends Node2D

@export var animation: AnimationPlayer = null

var is_play: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("Intro")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("click") and not is_play:
		is_play = true
		animation.play("Outro")
	pass

func switch_scene():
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
	pass
