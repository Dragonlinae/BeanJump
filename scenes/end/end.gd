extends CanvasLayer

@export var animation: AnimationPlayer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("RESET")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_end():
	animation.play("end")

func switch_scene():
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
