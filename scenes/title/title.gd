extends Node2D

@export var animation: AnimationPlayer = null
@export var music_button: Button = null
@export var credits_button: Button = null
@export var credits: CanvasLayer = null
@export var music_sprite: Sprite2D = null
@export var music_off_texture: CompressedTexture2D = null
@export var music_on_texture: CompressedTexture2D = null

var music_on: bool = false
var music_singleton: AudioStreamPlayer = null
var is_play: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
  music_singleton = get_node("/root/Music")
  music_button.pressed.connect(self._on_Music_Button_pressed)
  credits_button.pressed.connect(self._on_Credits_Button_pressed)
  animation.play("Intro")
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if Input.is_action_just_pressed("click") and not is_play and not music_button.is_hovered() and not credits_button.is_hovered():
    if credits.visible:
      credits.visible = false
    else:
      is_play = true
      animation.play("Outro")
  pass

func switch_scene():
  get_tree().change_scene_to_file("res://scenes/game/game.tscn")
  pass


func _on_Music_Button_pressed():
  print("Button pressed")
  music_on = not music_on
  if music_on:
    music_sprite.texture = music_on_texture
    music_singleton.play()
  else:
    music_sprite.texture = music_off_texture
    music_singleton.stop()

func _on_Credits_Button_pressed():
  credits.visible = not credits.visible
