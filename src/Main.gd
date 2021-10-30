extends Spatial

var games = []
var thumbs = []
var index : int
var current_game_pid : int

var tween_speed := 0.5

onready var tween := get_node("Tween")

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
    var thumb := MeshInstance.new()
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
      _interpolate_thumb_translation(thumb, -1 * x, -1)
      _interpolate_thumb_rotation(thumb, 75)
    elif i > index:
      _interpolate_thumb_translation(thumb, x, -1)
      _interpolate_thumb_rotation(thumb, -75)
    else:
      _interpolate_thumb_translation(thumb, 0, 0)
      _interpolate_thumb_rotation(thumb, 0)

      _update_game_description(games[i])

  tween.start()

func _interpolate_thumb_translation(thumb, x, z) -> void:
  tween.interpolate_property(thumb, "translation", thumb.translation, Vector3(x, 0, z), tween_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)


func _interpolate_thumb_rotation(thumb, degrees) -> void:
  tween.interpolate_property(thumb, "rotation_degrees", thumb.rotation_degrees, Vector3(90, degrees, 0), tween_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)


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
