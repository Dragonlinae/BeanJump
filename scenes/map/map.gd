extends TileMap

@export var water_layer: TileMap = null

const directions = [0, 1, 0, -1, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass

func create_island(target_local_coord, dir):
  var next_dir = randi_range(0, 1) * 2 - 1
  var tile_pos = local_to_map(target_local_coord)
  if dir == 1:
    tile_pos.x += randi_range(3, 5)
    for x in range(local_to_map(target_local_coord).x, tile_pos.x + 1):
      water_layer.set_cells_terrain_connect(0, [Vector2i(x, tile_pos.y)], 0, 1)
  else:
    tile_pos.y -= randi_range(3, 5)
    for y in range(tile_pos.y, local_to_map(target_local_coord).y + 1):
      water_layer.set_cells_terrain_connect(0, [Vector2i(tile_pos.x, y)], 0, 1)
  
  var end_tile = {"pos": tile_pos, "dir": next_dir}

  # island creation via bfs
  var queue = [tile_pos]
  for i in randi_range(1, 8):
    var randind = randi_range(0, queue.size() - 1)
    var current = queue[randind]
    queue[randind] = queue[queue.size() - 1]
    queue.pop_back()
    set_cells_terrain_connect(0, [current], 0, 0)

    if next_dir == 1:
      if current.x > end_tile["pos"].x or (current.x == end_tile["pos"].x and current.y <= end_tile["pos"].y):
        end_tile["pos"] = current
      for j in range(4):
        var next = current + Vector2i(directions[j], directions[j + 1])
        if dir == 1:
          if (next.x >= tile_pos.x):
            queue.append(next)
        else:
          if (next.y <= tile_pos.y):
            queue.append(next)
    else:
      if current.y < end_tile["pos"].y or (current.y == end_tile["pos"].y and current.x >= end_tile["pos"].x):
        end_tile["pos"] = current
      for j in range(4):
        var next = current + Vector2i(directions[j], directions[j + 1])
        if dir == 1:
          if (next.x >= tile_pos.x):
            queue.append(next)
        else:
          if (next.y <= tile_pos.y):
            queue.append(next)

  return end_tile
