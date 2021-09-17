extends Node2D

var games = []
var index := 0
var current_game_pid: int

func _ready() -> void:
  var configs = []
  var dir = Directory.new()
  dir.open('res://configs')
  dir.list_dir_begin()
    
  var filename = dir.get_next()
  while filename != "":
    if filename.ends_with(".json"):
      configs.append(dir.get_current_dir() + "/" + filename)
    filename = dir.get_next()

  dir.list_dir_end()
  
  configs.sort()

  for config in configs:
    var file = File.new()
    file.open(config, file.READ)
    var json = file.get_as_text()
    var json_data = JSON.parse(json).result
    file.close()
    
    # TODO: validate config data
    games.append(json_data)
    print(json_data)
  
  pass

func _input(event: InputEvent) -> void:
  if event is InputEventKey and event.pressed:
    match event.scancode:
      KEY_LEFT:
        _move_index(-1)
        print(games[index].name)
      KEY_RIGHT:
        _move_index(1)
        print(games[index].name)
      KEY_ENTER:
        print("launching " + games[index].name)
        current_game_pid = OS.execute("games/" + games[index].filename, [], false)
        print("current game PID - " + str(current_game_pid))
        OS.execute("bin/idle_check", [current_game_pid, OS.get_process_id()], false)

func _move_index(n: int) -> void:
  var i := index + n
  if i == games.size():
    index = 0
  elif i == -1:
    index = games.size() - 1
  else:
    index = index + n
