extends Node2D

@export var dragon_beans: Array[CharacterBody2D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func change_bean(lives):
  var bean_ind = dragon_beans.size() - lives
  for bean in dragon_beans:
    bean.visible = false
    bean.state = bean.State.HIDDEN
  dragon_beans[bean_ind].visible = true

func get_bean(lives):
  var bean_ind = dragon_beans.size() - lives
  return dragon_beans[bean_ind]
