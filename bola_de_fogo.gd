extends Area2D

@onready var animation = $AnimatedSprite2D
const SPEED = 200
var direction = 1
var projectileOwner = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("default")
	var destroy = Timer.new()
	destroy.wait_time = 10
	destroy.connect("timeout", func():
		self.queue_free()
		destroy.queue_free())
	add_child(destroy)
	destroy.start()

func _physics_process(delta: float) -> void:
	if direction > 0:
		position.x += SPEED * delta
		$AnimatedSprite2D.flip_h = false
	elif direction < 0:
		position.x -= SPEED * delta
		$AnimatedSprite2D.flip_h = true


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.name != projectileOwner:
			body.queue_free()
			self.queue_free()
