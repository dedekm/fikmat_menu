extends Spatial

var games = []
var index : int
var current_game_pid : int

var tween_speed := 0.5

onready var tween := get_node("Tween")
onready var game_description := get_node("GameDescription")

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

  var i := 0
  while games.size() <= 9:
    games.push_back(games[i].duplicate())
    i += 1

  index = floor(games.size() / 2)

  for g in games:
    var thumb := MeshInstance.new()
    thumb.mesh = PlaneMesh.new()
    var texture := load("res://games/" + g.thumb)
    var material = SpatialMaterial.new()
    material.albedo_texture = texture
    thumb.mesh.surface_set_material(0, material)
    thumb.rotation_degrees.x = 90

    add_child(thumb)
    g.thumb_instance = thumb

  _update_thumbs()


func _update_thumbs(direction = 0) -> void:
  for i in games.size():
    var x = 2 + 0.3 * abs(i - index)
    var thumb = games[i].thumb_instance

    print(games[i].title, " i: ",i , " x: ", x)
    print(i >= games.size() - 1)
    if i < index:
      if direction > 0 && i == 0:
        _interpolate_thumb_translation(thumb, -1 * x, -1.5, false)
        _interpolate_thumb_rotation(thumb, 75, false)
      else:
        _interpolate_thumb_translation(thumb, -1 * x, -1.5)
        _interpolate_thumb_rotation(thumb, 75)
    elif i > index:
      if direction < 0 && i == games.size() - 1:
        _interpolate_thumb_translation(thumb, x, -1.5, false)
        _interpolate_thumb_rotation(thumb, -75, false)
      else:
        _interpolate_thumb_translation(thumb, x, -1.5)
        _interpolate_thumb_rotation(thumb, -75)
    else:
      _interpolate_thumb_translation(thumb, 0, 0)
      _interpolate_thumb_rotation(thumb, 0)

      _update_game_description(games[i])

  tween.start()


func _interpolate_thumb_translation(thumb, x, z, animate = true) -> void:
  if animate:
    tween.interpolate_property(thumb, "translation", thumb.translation, Vector3(x, 0, z), tween_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
  else:
    thumb.translation = Vector3(x, 0, z)


func _interpolate_thumb_rotation(thumb, degrees, animate = true) -> void:
  if animate:
    tween.interpolate_property(thumb, "rotation_degrees", thumb.rotation_degrees, Vector3(90, degrees, 0), tween_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
  else:
    thumb.rotation_degrees = Vector3(90, degrees, 0)


func _update_game_description(data) -> void:
  game_description.text = data.title + "\n" + data.authors


func _input(event: InputEvent) -> void:
  if event is InputEventKey and event.pressed:
    match event.scancode:
      KEY_LEFT, KEY_A:
        _move_index(-1)
        _update_thumbs(-1)
      KEY_RIGHT, KEY_D:
        _move_index(1)
        _update_thumbs(1)
      KEY_ENTER, KEY_V, KEY_B, KEY_K, KEY_L:
        print("launching " + games[index].title)
        current_game_pid = OS.execute("./games/" + games[index].filename, [], false)
        print("current game PID - " + str(current_game_pid))
        OS.execute("./bin/create_pid_file", [current_game_pid, "game"], true)


func _notification(what) -> void:
  if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
    print("focus in")
  elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
    print("focus out")


func _move_index(n: int) -> void:
  if n > 0:
    games.push_front(games.pop_back())
  elif n < 0:
    games.push_back(games.pop_front())
