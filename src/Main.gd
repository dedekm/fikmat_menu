extends Node2D

const games = ["pong1.x86_64",
               "pong2.x86_64"]

var index := 0
var current_game_pid: int

func _ready() -> void:
  print(OS.get_process_id())
  pass

func _input(event: InputEvent) -> void:
  if event is InputEventKey and event.pressed:
    match event.scancode:
      KEY_LEFT:
        _move_index(-1)
        print(games[index])
      KEY_RIGHT:
        _move_index(1)
        print(games[index])
      KEY_ENTER:
        print("launching " + games[index])
        current_game_pid = OS.execute("games/" + games[index], [], false)
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
