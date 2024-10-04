extends Node

func _ready():
  # CHeck if the file exists, make a new one if it doesn't
  var save_file = FileAccess.open("user://gamesave.dat", FileAccess.READ)
  if save_file == null:
    save_file = FileAccess.open("user://gamesave.dat", FileAccess.WRITE)
    save_file.store_line(JSON.stringify({}))
    save_file.close()

func save_data(key, data):
  var save_file = FileAccess.open("user://gamesave.dat", FileAccess.READ)
  var json = JSON.new()
  var error = json.parse(save_file.get_as_text())
  if error != OK:
    print("Error parsing JSON")
    return
  var saved_data = json.data
  saved_data[key] = data
  save_file.close()

  save_file = FileAccess.open("user://gamesave.dat", FileAccess.WRITE)
  save_file.store_line(JSON.stringify(saved_data, "  "))
  save_file.close()


func load_data(key):
  var save_file = FileAccess.open("user://gamesave.dat", FileAccess.READ)
  var json = JSON.new()
  var error = json.parse(save_file.get_as_text())
  if error != OK:
    print("Error parsing JSON")
    return
  var saved_data = json.data
  save_file.close()
  if key not in saved_data:
    return null
  return saved_data[key]
