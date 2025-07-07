extends Node

#region Variables
var score = 0
var health := 200

signal score_reached_50
signal score_reached_100
signal score_reached_150
signal score_reached_200

@onready var healthlabel: Label = $Health
@onready var scorecount: Label = $Score
@onready var enemy_spawner: Node2D = $"Enemy Spawner"
#endregion

#region Health Label
func _on_player_minushealth() -> void:
	if health:
		health -= 20 
		healthlabel.text = "HP: %d" % health
	
#endregion
#region Scoring Logic

func add_point():
	score += 10
	scorecount.text = "Score: %d" % score
	
	if score == 50:
		emit_signal("score_reached_50")
	if score == 100:
		emit_signal("score_reached_100")
	if score == 150:
		emit_signal("score_reached_150")
	if score == 200:
		emit_signal("score_reached_200")
#endregion
