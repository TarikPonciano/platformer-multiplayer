#extends CharacterBody2D
#
#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
## Quando o nó é carregado, garantimos que o cliente tem autoridade sobre o jogador
#func _ready() -> void:
	#if is_multiplayer_authority():
		## Define a autoridade corretamente para o jogador
		#set_multiplayer_authority(multiplayer.get_unique_id())  # Atribui autoridade ao cliente correto
#
#func _physics_process(delta: float) -> void:
	## Só permite o movimento do personagem se o cliente tiver autoridade sobre ele
	#if is_multiplayer_authority():
		#var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		#velocity = direction * SPEED
		#move_and_slide()  # Aplica o movimento
extends CharacterBody2D

const SPEED = 300.0
@onready var rotulo_nome = $NomeJogador

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
	if is_multiplayer_authority(): #Verifica se autoridade 
		var camera = Camera2D.new()
		add_child(camera)
		camera.limit_left = -1280
		camera.limit_top = -768
		camera.limit_right = 1280
		camera.limit_bottom = 768
		camera.zoom = Vector2(1, 1)
	
func _physics_process(delta: float) -> void:
	if (is_multiplayer_authority()):
		
		var direction_horizontal := Input.get_axis("ui_left", "ui_right")
		if direction_horizontal:
			velocity.x = direction_horizontal * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		
		var direction_vertical := Input.get_axis("ui_up", "ui_down")
		if direction_vertical:
			velocity.y = direction_vertical * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
