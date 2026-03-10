extends Node2D

@onready var path_follow_2d: PathFollow2D = %PathFollow2D
@onready var sprite: Sprite2D = %Sprite2D
@onready var sfx_cucumber: AudioStreamPlayer2D = %SFX
@onready var circle_distance_limit: Body2D = %DistanceLimit
@onready var circle_distance_deadzone: Body2D = %DeadZone

@onready var target_pos: Vector2 = global_position

@export var speed: float = 2.8
@export var score_max: int = 50

enum states
{
	MOVE,
	CLICKED,
	STOPPED
}
var state_machine: states = states.MOVE
var progress: float = 0
var direction_reversed: bool = false

signal cucumber_stopped(target_misses : bool)

###### BUILT-IN FUNCTIONS ######
func _process(delta: float) -> void:
	match state_machine:
		states.MOVE:
			_slide(delta)
			if Input.is_action_just_pressed("MOUSE_BUTTON_LEFT"):
				state_machine = states.CLICKED
				_score()
		states.CLICKED:
			if Input.is_action_just_released("MOUSE_BUTTON_LEFT"):
				state_machine = states.STOPPED
		states.STOPPED:
			pass

###### CUSTOM FUNCTIONS ######
func _slide(delta: float) -> void:
	if not direction_reversed:
		progress += delta * speed
	elif direction_reversed:
		progress -= delta * speed
	
	if progress >= 1:
		progress = 1
		direction_reversed = true
	if progress <= 0:
		progress = 0
		direction_reversed = false
	
	path_follow_2d.progress_ratio = Ease.InOutSine(progress)
	sprite.position = path_follow_2d.position

func _score() -> void:
	var score_dist_limit: float = circle_distance_limit.shape.radius
	var score_dist_dead_zone: float = 1.0 - (circle_distance_deadzone.shape.radius / score_dist_limit)
	
	var dist: float = sprite.global_position.distance_to(target_pos)
	var dist_pourcentage: float = 1.0 - (dist / score_dist_limit)
	
	dist_pourcentage = max(0.0, dist_pourcentage)
	if (dist_pourcentage >= score_dist_dead_zone):
		dist_pourcentage = 1.0
	
	var score: int = int(dist_pourcentage * score_max)
	GameManager.score += score
	sfx_cucumber.play()
	
	if score <= 0:
		cucumber_stopped.emit(true)
	elif score > 0:
		cucumber_stopped.emit(false)
