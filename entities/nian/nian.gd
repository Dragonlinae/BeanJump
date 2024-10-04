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
  INTRO
}

@export var state: State = State.IDLE
@export var fall_state: int = 0
