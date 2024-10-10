extends CharacterBody2D

enum State {
  IDLE,
  WALK,
  CELEBRATE,
  CROUCH,
  JUMP,
  JUMPEND,
  FALL,
  SPLASH,
  END,
  INTRO,
  HIDDEN
}

@export var state: State = State.HIDDEN
@export var fall_state: int = 0
@export var jump_bar_mask: Panel = null
@export var jump_bar: TextureProgressBar = null
@export var hold_time: float = 0

var jump_bar_pos: Vector2 = Vector2(0, 0)

func _ready():
  jump_bar_pos = jump_bar_mask.position


func _process(delta):
  if (state == State.CROUCH):
    hold_time += delta * 50
    jump_bar.value = hold_time
    if (hold_time > 100):
      jump_bar_mask.position = jump_bar_pos + Vector2(randi() % 10 - 5, randi() % 10 - 5)
  else:
    hold_time = 0
    jump_bar.value = 0
