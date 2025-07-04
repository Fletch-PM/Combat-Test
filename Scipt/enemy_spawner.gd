extends Node2D

var enemy := preload("res://Scene/enemy.tscn")
var spawn_points: Array[Marker2D] = []
var main: Node = null

func _ready() -> void:
	randomize()

	# Gather all spawn points first
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	if spawn_points.is_empty():
		push_warning("No spawn points found in EnemySpawner.")
	else:
		print("Spawn points: ", spawn_points.size())

	# Defer the timer start until fully added to the tree
	call_deferred("_begin_spawn")

func _begin_spawn() -> void:
	main = get_tree().get_current_scene()

	if main == null:
		push_error("Main scene is null! Cannot spawn enemies.")
		return

	$SpawnTimer.start()
	print("Spawn timer started after entering scene.")


func _on_spawn_timer_timeout() -> void:
	if spawn_points.is_empty() or main == null:
		return

	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var vampire = enemy.instantiate()
	vampire.position = spawn_point.position
	main.add_child(vampire)

	print("Spawned enemy at ", vampire.position)
