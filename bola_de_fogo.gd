extends Area2D

@onready var animation = $AnimatedSprite2D
const SPEED = 200
var direction = 1 #Variavel que define a direção do movimento e da animação
var projectileOwner = "" #Define o dono da bala
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("default")
	#Lógica para despawn da bala. Cria-se um timer e define o tempo de 10 segundos, quando o tempo encerra é executado uma função que elimina a bala e o timer.
	var destroy = Timer.new()
	destroy.wait_time = 10
	destroy.connect("timeout", func():
		self.queue_free()
		destroy.queue_free())
	add_child(destroy)
	destroy.start()

func _physics_process(delta: float) -> void:
	#Lógica para a orientação da direção da bala. Foi criado uma informação no projétil chamada direction. Dependo da direção são alterados a formula de mudança de posição e o lado da animação.
	if direction > 0:
		position.x += SPEED * delta
		$AnimatedSprite2D.flip_h = false
	elif direction < 0:
		position.x -= SPEED * delta
		$AnimatedSprite2D.flip_h = true


func _on_body_entered(body: Node2D) -> void:
	#Colisão com jogador. Primeiro checamos se o objeto com que a bala colidiu faz parte do grupo de jogadores (verificar a seção grupos na aba "Nó" do inspetor do objeto jogador)
	#Depois checamos se o corpo jogador que colidiu é diferente do jogador que gerou a bala.
	#Destruimos o jogador e a bala. Essa lógica garante que só é possivel afetar inimigos com nossa própria bala.
	if body.is_in_group("player"):
		if body.name != projectileOwner:
			body.queue_free()
			self.queue_free()
