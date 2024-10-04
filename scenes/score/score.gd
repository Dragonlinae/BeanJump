extends CanvasLayer

@export var score_label: RichTextLabel = null

var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func add_score(land_count: int):
  score += 5 * (land_count ** 2)
  score_label.text = "SCORE:" + str(score)

func _exit_tree():
  var hi_score = Gamesave.load_data("score")["hi_score"]
  if score > hi_score:
    Gamesave.save_data("score", save())

func save():
  var data = {
    "hi_score": score
  }
  return data
