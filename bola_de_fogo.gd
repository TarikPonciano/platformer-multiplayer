extends Area2D

@onready var animation = $AnimatedSprite2D
const SPEED = 350
var direction = 1 # Variável que define a direção do movimento e da animação
var projectileOwner = "" # Define o dono da bala

# Chamado quando o projétil entra no mundo
func _ready() -> void:
	animation.play("default")
	# Lógica para despawn da bala
	var destroy = Timer.new()
	destroy.wait_time = 10
	destroy.connect("timeout", func():
		self.queue_free()
		destroy.queue_free())
	add_child(destroy)
	destroy.start()

func _physics_process(delta: float) -> void:
	# Lógica para a orientação da direção da bala
	if direction > 0:
		position.x += SPEED * delta
		$AnimatedSprite2D.flip_h = false
	elif direction < 0:
		position.x -= SPEED * delta
		$AnimatedSprite2D.flip_h = true

	# Sincroniza a posição do projétil entre os clientes
	rpc("sicronizacao_possicao_projetil", position)

# Sincroniza a posição do projétil com todos os clientes
@rpc
func sicronizacao_possicao_projetil(position: Vector2):
	self.position = position

# Colisão com o jogador
func _on_body_entered(body: Node2D) -> void:
	# Colisão com jogador. Primeiro checamos se o objeto com que a bala colidiu faz parte do grupo de jogadores
	# Depois checamos se o corpo jogador que colidiu é diferente do jogador que gerou a bala.
	# Destruímos o jogador e a bala. Essa lógica garante que só é possível afetar inimigos com nossa própria bala.
	if body.is_in_group("player"):
		if body.name != projectileOwner:
			body.queue_free()
			self.queue_free()
