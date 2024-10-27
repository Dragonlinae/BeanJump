extends ParallaxBackground

@export var scroll_base_scroll_speed: Vector2 = Vector2(-40, 20)

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  scroll_base_offset += scroll_base_scroll_speed * delta
  pass
