extends Area2D

@onready var animation = $AnimatedSprite2D
const SPEED = 200
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("default")


func _physics_process(delta: float) -> void:
	position.x += SPEED * delta
