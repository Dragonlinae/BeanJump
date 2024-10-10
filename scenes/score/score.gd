extends CanvasLayer

@export var score_label: RichTextLabel = null
@export var lives: Node2D = null

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
  var score_data = Gamesave.load_data("score")
  if score_data == null or score_data["hi_score"] < score:
    Gamesave.save_data("score", save())

func save():
  var data = {
    "hi_score": score
  }
  return data

func lose_life():
  return lives.dec_life()

func get_life():
  return lives.get_life()
