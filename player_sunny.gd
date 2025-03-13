extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var projectile:PackedScene
var shooting = false
var cooldown_shoot = false
@onready var animation = $AnimatedSprite2D
@onready var rotulo = $Label


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	# Usando get_tree().multiplayer.local_peer.id para acessar o peer_id corretamente
	#set_multiplayer_authority(get_tree().multiplayer.local_peer.id)
	
	if is_multiplayer_authority(): # Verifica se é autoridade 

		var camera = Camera2D.new()
		add_child(camera)
		camera.limit_left = -289
		camera.limit_top = 0
		camera.limit_right = 1440
		camera.limit_bottom = 640
		camera.zoom = Vector2(1.5, 1.5)

func _ready() -> void:
	if is_multiplayer_authority():
		rotulo.text = str(get_parent().campoNome.text)
		if rotulo.text == "":
			rotulo.text = "Anônimo"
		rpc_id(1, "update_names", rotulo.text)
		var spawns = get_parent().get_node("SpawnPoints").get_children()
		var random = RandomNumberGenerator.new()
		var spawnRandom = spawns[random.randi_range(0, spawns.size() - 1)]
		self.position = spawnRandom.position
		

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():  # Garantir que o código de movimento seja feito apenas pela autoridade
		
		if animation.animation == "death":
			return

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
		if Input.is_action_just_pressed("shoot") and cooldown_shoot == false:
			create_projectile()
		
		# Atualiza as animações
		_update_animation()

		# Movimenta o personagem
		move_and_slide()
		
func create_projectile():
	
	rpc_id(1, "create_projectile_multiplayer", animation.flip_h, self.position)
	cooldown_shoot = true
	shooting = true
	#Lógica para resetar a animação de tiro e adicionar um delay para atirar novamente
	#Criamos um Timer e configuramos o tempo dele
	var cooldownAnimacao = Timer.new()
	cooldownAnimacao.wait_time = 0.2
	#Estamos fazendo a conexão de sinal similar ao que é feito na aba "Nó" do inspetor, porém indicamos qual evento está acontecendo e na sequência criamos uma função anônima que será executada ao acabar o tempo
	cooldownAnimacao.connect("timeout", func():
		shooting = false
		cooldownAnimacao.queue_free())
	#Na função acima é importante resetar a variavel shooting e também instruir para o timer ser deletado quando seu trabalho terminar
	add_child(cooldownAnimacao)
	#Adicionamos o timer e depois inicializamos sua contagem
	cooldownAnimacao.start()
	
	var cooldownTiro = Timer.new()
	cooldownTiro.wait_time = 1
	cooldownTiro.connect("timeout", func():
		cooldown_shoot = false
		cooldownTiro.queue_free())
	add_child(cooldownTiro)
	cooldownTiro.start()
	

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
		
		
		animation.play("death")
		$CollisionShape2D.disabled = true
		await animation.animation_finished
		
		self.position = spawnRandom.position
		$CollisionShape2D.disabled = false
		animation.play("idle")
		

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
	

@rpc("any_peer", "call_local", "reliable")
func update_names(novo_nome):
	get_parent().update_names(multiplayer.get_remote_sender_id(),novo_nome)
	
