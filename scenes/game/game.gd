extends Node2D

@export var dragon_bean: CharacterBody2D = null
@export var path: Path2D = null
@export var path_follow: PathFollow2D = null
@export var tilemap: TileMap = null
@export var camera: Camera2D = null
@export var score: CanvasLayer = null
@export var end_screen: CanvasLayer = null
@export var characters: Node2D = null
@export var mouse_sprite: AnimatedSprite2D = null

var State
var hold_time: float = 0
var path_follow_true_progress: float = 0
var last_fall_state: int = 0
var end_tiles: Array = [] # No queues sadge. // TODO: Replace with a circular array for that tiny boost
var nav_agent: NavigationAgent2D = null
var facing_dir: int = 1
var lost: bool = false

const diagonal_dist: Vector2 = Vector2(305, -176)
const diagonal_in: Vector2 = Vector2(-90, -270)

# Called when the node enters the scene tree for the first time.
func _ready():
  State = dragon_bean.State
  characters.change_bean(score.get_life())
  dragon_bean = characters.get_bean(score.get_life())
  dragon_bean.state = State.INTRO
  nav_agent = path.get_node("NavAgent")
  nav_agent.set_navigation_map(tilemap.get_navigation_map(0))
  nav_agent.target_position = path.global_position
  end_tiles.append(tilemap.create_island(path.position, 1))
  
  while end_tiles.size() < 10:
    end_tiles.append(tilemap.create_island(tilemap.map_to_local(end_tiles[end_tiles.size() - 1]["pos"]), end_tiles[end_tiles.size() - 1]["dir"]))

  path.scale.x = facing_dir * abs(path.scale.x)

  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

  match dragon_bean.state:
    State.IDLE:
      Engine.time_scale = 1.0
      mouse_sprite.play("off")
      mouse_sprite.visible = false
      Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
      if Input.is_action_just_pressed("click"):
        dragon_bean.state = State.CROUCH
        hold_time = 0
    State.WALK:
      if nav_agent.is_navigation_finished(): # Reset all modifications to path
        dragon_bean.state = State.IDLE
        path.global_position = nav_agent.target_position
        camera.global_position = path.global_position
        path.scale.x = facing_dir * abs(path.scale.x)
        dragon_bean.scale.x = abs(dragon_bean.scale.x)
    State.CELEBRATE:
      pass
    State.CROUCH:
      if Input.is_action_just_released("click"): # On release, calculate jump distance
        dragon_bean.state = State.JUMP
        path_follow.rotates = true
        path.curve.set_point_position(1, ceil(hold_time * 5) * diagonal_dist)
        path.curve.set_point_in(1, ceil(hold_time * 5) * diagonal_in)

        if abs(path.to_global(path.curve.get_point_position(1)).x - camera.global_position.x) > camera.get_viewport_rect().size.x / 3 or abs(path.to_global(path.curve.get_point_position(1)).y - camera.global_position.y) > camera.get_viewport_rect().size.y / 3:
          camera.global_position = path.to_global(path.curve.get_point_position(1))
    State.JUMP:
      mouse_sprite.visible = true
      Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
      if path_follow_true_progress >= 0.8: # Check if misses path
        var tile_pos = tilemap.local_to_map(path.position + path.curve.get_point_position(1) * path.scale)
        if not tilemap.get_cell_tile_data(0, tile_pos) or tilemap.get_cell_tile_data(0, tile_pos).terrain_set != 0:
          dragon_bean.state = State.FALL
          lost = true
        else:
          dragon_bean.state = State.JUMPEND
    State.JUMPEND:
      if path_follow_true_progress >= 1:
        dragon_bean.state = State.CELEBRATE
    State.FALL:
      pass
    State.SPLASH:
      pass
    State.END:
      if not lost:
        path.z_index = 1
        path_follow_true_progress = 0
        path_follow.progress_ratio = 0
        path_follow.rotates = false
        path_follow.rotation_degrees = 0
        path_follow.v_offset = 0

        # Reset path via tilemap to prevent accumulation of error in position
        path.position = tilemap.map_to_local(tilemap.local_to_map(path.position + path.curve.get_point_position(1) * path.scale)) + Vector2(0, 1 - tilemap.tile_set.tile_size.y / 2.0)
        path.scale.x = abs(path.scale.x)

        var to_remove = 0

        # Determine which island got landed on
        for i in range(end_tiles.size()):
          var tile = end_tiles[i]["pos"]
          nav_agent.target_position = tilemap.to_global(tilemap.map_to_local(tile) + Vector2(0, 1 - tilemap.tile_set.tile_size.y / 2.0))
          if not nav_agent.is_target_reachable():
            to_remove = i
          else:
            to_remove = i
            break

        for i in range(to_remove):
          end_tiles.remove_at(0)

        while end_tiles.size() < 11:
          end_tiles.append(tilemap.create_island(tilemap.map_to_local(end_tiles[end_tiles.size() - 1]["pos"]), end_tiles[end_tiles.size() - 1]["dir"]))

        facing_dir = end_tiles[0]["dir"]
        end_tiles.remove_at(0)

        score.add_score(to_remove + 1)
        
        camera.global_position = path.global_position

        dragon_bean.state = State.WALK
      else:
        if score.lose_life():
          lost = false
          path.z_index = 1
          path_follow_true_progress = 0
          path_follow.progress_ratio = 0
          path_follow.rotates = false
          path_follow.rotation_degrees = 0
          path_follow.v_offset = 0

          path.global_position = nav_agent.target_position
          camera.global_position = path.global_position
          characters.change_bean(score.get_life())
          dragon_bean = characters.get_bean(score.get_life())
          dragon_bean.state = State.INTRO
        else:
          dragon_bean.visible = false
          Engine.time_scale = 1.0
          mouse_sprite.play("off")
          mouse_sprite.visible = false
          Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
          end_screen.play_end()
          set_process(false)
    State.INTRO:
      pass

  match dragon_bean.state:
    State.IDLE:
      pass
    State.WALK: # Use nav_agent to move along path
      var next_position = nav_agent.get_next_path_position()
      var direction = next_position - path.global_position
      var direction_norm = direction.normalized() * 200 * delta
      if direction.length() < direction_norm.length():
        path.global_position = next_position
      else:
        path.global_position += direction_norm

      camera.global_position = path.global_position

      if direction.x > 0:
        dragon_bean.scale.x = abs(dragon_bean.scale.x)
      else:
        dragon_bean.scale.x = -abs(dragon_bean.scale.x)

    State.CELEBRATE:
      path_follow_true_progress = 1
      path_follow.progress_ratio = 1
      path_follow.rotation_degrees = 0
      pass
    State.CROUCH:
      hold_time += delta
    State.JUMP:
      path_follow_true_progress += delta
      path_follow.progress_ratio = path_follow_true_progress
    State.JUMPEND:
      path_follow_true_progress += delta
      path_follow.progress_ratio = path_follow_true_progress
      path_follow.rotation_degrees = cubic_interpolate(path_follow.rotation_degrees, 10, 10, 0, (path_follow_true_progress - 0.8) * 5)
    State.FALL:
      path_follow_true_progress += delta / 12
      if dragon_bean.fall_state != last_fall_state:
        last_fall_state = dragon_bean.fall_state
        path_follow.progress_ratio = path_follow_true_progress
    State.SPLASH:
      path.z_index = 0
      path_follow_true_progress = 1
      path_follow.progress_ratio = 1
      path_follow.rotates = false
      path_follow.rotation_degrees = 90
      path_follow.v_offset = 50
      pass
    State.END:
      pass
    State.INTRO:
      pass

func _input(event):
  if event.is_action_pressed("click") and not dragon_bean.state == State.CROUCH and not dragon_bean.state == State.IDLE:
    Engine.time_scale = 5.0
    mouse_sprite.play("on")
  elif event.is_action_released("click"):
    Engine.time_scale = 1.0
    mouse_sprite.play("off")
  if event is InputEventMouseMotion:
    mouse_sprite.position = event.global_position
