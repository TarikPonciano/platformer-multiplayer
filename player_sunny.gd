extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var projectile:PackedScene
var shooting = false
@onready var animation = $AnimatedSprite2D

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	# Usando get_tree().multiplayer.local_peer.id para acessar o peer_id corretamente
	#set_multiplayer_authority(get_tree().multiplayer.local_peer.id)
	
	if is_multiplayer_authority(): # Verifica se é autoridade 
		var camera = Camera2D.new()
		add_child(camera)
		camera.limit_left = -220
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

	rpc_id(1, "create_projectile_multiplayer", animation.flip_h, self.position)
	
	#Lógica para resetar a animação de tiro e adicionar um delay para atirar novamente
	#Criamos um Timer e configuramos o tempo dele
	var cooldown = Timer.new()
	cooldown.wait_time = 1
	#Estamos fazendo a conexão de sinal similar ao que é feito na aba "Nó" do inspetor, porém indicamos qual evento está acontecendo e na sequência criamos uma função anônima que será executada ao acabar o tempo
	cooldown.connect("timeout", func():
		shooting = false
		cooldown.queue_free())
	#Na função acima é importante resetar a variavel shooting e também instruir para o timer ser deletado quando seu trabalho terminar
	add_child(cooldown)
	#Adicionamos o timer e depois inicializamos sua contagem
	cooldown.start()
	

func _update_animation() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	
	#Adicionado o estado shooting para as animações. Ele vem primeiro pois esse estado deve executar independente do movimento.
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


func death():
	if is_multiplayer_authority():
		print("Death Rodou")
		var spawns = get_parent().get_node("SpawnPoints").get_children()
		var random = RandomNumberGenerator.new()
		var spawnRandom = spawns[random.randi_range(0, spawns.size() - 1)]
		
		self.position = spawnRandom.position

@rpc("any_peer", "call_local", "reliable")
func create_projectile_multiplayer(direcao, posicao):
	var novoProjetil = projectile.instantiate()
	
	novoProjetil.projectileOwner = str(multiplayer.get_remote_sender_id())
	
	if direcao == false:
		novoProjetil.direction = 1
		novoProjetil.position = Vector2(posicao.x + 55, posicao.y)
	elif direcao == true:
		novoProjetil.direction = -1
		novoProjetil.position = Vector2(posicao.x - 55, posicao.y)
		
	get_parent().add_child(novoProjetil, true)
	
		
