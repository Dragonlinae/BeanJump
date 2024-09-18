extends Node2D

@export var dragon_bean: CharacterBody2D = null
@export var path: Path2D = null
@export var path_follow: PathFollow2D = null
@export var tilemap: TileMap = null
@export var camera: Camera2D = null
@export var score: CanvasLayer = null
@export var end_screen: CanvasLayer = null

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
	nav_agent = path.get_node("NavAgent")
	nav_agent.set_navigation_map(tilemap.get_navigation_map(0))
	end_tiles.append(tilemap.create_island(path.position, 1))
	
	while end_tiles.size() < 10:
		end_tiles.append(tilemap.create_island(tilemap.map_to_local(end_tiles[end_tiles.size() - 1]["pos"]), end_tiles[end_tiles.size() - 1]["dir"]))

	path.scale.x = facing_dir * abs(path.scale.x)

	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	match dragon_bean.state:
		State.IDLE:
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
			if path_follow_true_progress >= 0.8: # Check if misses path
				var tile_pos = tilemap.local_to_map(path.position + path.curve.get_point_position(1) * path.scale)
				if tilemap.get_cell_source_id(0, tile_pos) == -1:
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
				dragon_bean.visible = false
				end_screen.play_end()
				await get_tree().create_timer(5).timeout
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
			path_follow.v_offset = 125
			pass
		State.END:
			pass
		State.INTRO:
			pass
