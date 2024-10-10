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
