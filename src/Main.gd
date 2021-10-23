extends Spatial

var games = []
var thumbs = []
var index: int
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

  index = floor(games.size() / 2)
  
  for i in games.size():
    var thumb: = MeshInstance.new()
    thumb.mesh = PlaneMesh.new()
    
    var texture := load("res://assets/" + games[i].thumb)
    var material = SpatialMaterial.new()
    material.albedo_texture = texture
    thumb.mesh.surface_set_material(0, material)
    thumb.rotation_degrees.x = 90
    
    add_child(thumb)
    thumbs.append(thumb)
    
  _update_thumbs()

func _update_thumbs() -> void:
  for i in games.size():
    var x = 2 + 0.5 * abs(i - index)
    var thumb = thumbs[i]

    if i < index:
      thumb.translation.x = -1 * x
      thumb.translation.z = -1
      thumb.rotation_degrees.y = 75
    elif i > index:
      thumb.translation.x = x
      thumb.translation.z = -1
      thumb.rotation_degrees.y = -75
    else:
      thumb.translation.x = 0
      thumb.translation.z = 0
      thumb.rotation_degrees.y = 0

func _input(event: InputEvent) -> void:
  if event is InputEventKey and event.pressed:
    match event.scancode:
      KEY_LEFT:
        _move_index(-1)
        _update_thumbs()
      KEY_RIGHT:
        _move_index(1)
        _update_thumbs()
      KEY_ENTER:
        print("launching " + games[index].name)
        current_game_pid = OS.execute("games/" + games[index].filename, [], false)
        print("current game PID - " + str(current_game_pid))
        OS.execute("bin/create_pid_file", [current_game_pid, "game"], true)

func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
        print("focus in")
    elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
        print("focus out")

func _move_index(n: int) -> void:
  var i := index + n
  if i == games.size():
    index = 0
  elif i == -1:
    index = games.size() - 1
  else:
    index = index + n

  print(games[index].name)
