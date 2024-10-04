extends CanvasLayer

@export var animation: AnimationPlayer = null
@export var score_label: RichTextLabel = null

# Called when the node enters the scene tree for the first time.
func _ready():
  var score_data = Gamesave.load_data("score")
  if score_data != null:
    score_label.text = "HS: " + str(score_data["hi_score"])
  animation.play("Intro")
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func delete():
  queue_free()
  pass
