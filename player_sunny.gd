extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var projectile:PackedScene
var shooting = false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	# Usando get_tree().multiplayer.local_peer.id para acessar o peer_id corretamente
	#set_multiplayer_authority(get_tree().multiplayer.local_peer.id)
	
	if is_multiplayer_authority(): # Verifica se é autoridade 
		var camera = Camera2D.new()
		add_child(camera)
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = 1152
		camera.limit_bottom = 648
		camera.zoom = Vector2(1.5, 1.5)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():  # Garantir que o código de movimento seja feito apenas pela autoridade
		# Adiciona a gravidade
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Verifica o pulo
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Captura a direção do movimento
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		#Ação para atirar
		if Input.is_action_just_pressed("shoot") and shooting == false:
			create_projectile()
		
		# Atualiza as animações
		_update_animation()

		# Movimenta o personagem
		move_and_slide()
		
func create_projectile():
	
	var new_projectile = projectile.instantiate()
	new_projectile.position = Vector2(self.position.x + 15, self.position.y)
	shooting = true
	get_parent().add_child(new_projectile)
	
	var cooldown = Timer.new()
	cooldown.wait_time = 0.5
	cooldown.connect("timeout", func():
		shooting = false
		cooldown.queue_free())
	add_child(cooldown)
	cooldown.start()
	

func _update_animation() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		
	if shooting:
		$AnimatedSprite2D.play("shoot")
	elif velocity.y < 0:
		$AnimatedSprite2D.play("jump")
	elif velocity.y > 0:
		$AnimatedSprite2D.play("fall")
	elif velocity.x != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")
