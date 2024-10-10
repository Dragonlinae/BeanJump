extends Node2D

@export var arrow: Polygon2D = null

const pos: PackedInt32Array = [-150, -50, 50, 150]
var life: int = 4

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func dec_life():
  life -= 1
  update_life()
  return life
  
func update_life():
  if (life > 4 or life < 0):
    return
  if (life == 0):
    arrow.visible = false
    return
  arrow.transform.origin.x = pos[4 - life]

func get_life():
  return life
