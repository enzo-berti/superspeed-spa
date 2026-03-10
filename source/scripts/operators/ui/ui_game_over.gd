extends Control

@onready var button_mainmenu: Button = $VBoxContainer/button_mainmenu
@onready var button_retry: Button = $VBoxContainer/button_retry
@onready var sfx_button: AudioStreamPlayer2D = $sfx_button
@onready var sprite_gameover: AnimatedSprite2D = $sprite_gameover

@onready var best_score_label: LabelScore = $BestScoreTexture/ScoreLabel
@onready var score_label: LabelScore = $YourScoreTexture/ScoreLabel

@export var tween_intensity: float
@export var tween_duration: float

func _ready() -> void:
	if (GameManager.score > GameManager.best_score):
		GameManager.best_score = GameManager.score

	score_label.text_desired = str(GameManager.score)
	best_score_label.text_desired = str(GameManager.best_score)
	GameManager.score = 0
	GameManager.health = 3
	GameManager.patience_time = 40
	GameManager.win_clients = 0

func _process(_delta: float) -> void:
	btn_hovered(button_mainmenu)
	btn_hovered(button_retry)

func start_tween(object: Object, property: String, final_val: Variant, duration: float):
	var tween = create_tween()
	tween.tween_property(object, property, final_val, duration)

func btn_hovered(button: Button):
	button.pivot_offset = button.size/2
	if button.is_hovered():
		start_tween(button, "scale", Vector2.ONE*tween_intensity, tween_duration)
	else:
		start_tween(button, "scale", Vector2.ONE, tween_duration)


func _on_button_retry_pressed() -> void:
	sfx_button.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_packed(load(GameManager.GAME_SCENE_UID))


func _on_button_mainmenu_pressed() -> void:
	sfx_button.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_packed(load(GameManager.TITLE_SCREEN_SCENE_UID))
