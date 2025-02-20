#extends Node2D
#
## 1. Criar interface com botões
## Host e Join.
#
## 2. Criar a infraestrutura de
## conexão desses botões. 
## Código de Join Server
## Código de Create Server
#
## 3. Exibir informação na tela ou
## terminal, quando um usuário se 
## conectar.
#
## Configuração de rede
#var peer = ENetMultiplayerPeer.new()
#const ADDRESS = "127.0.0.1"
#const PORT = 3333
#@onready var log = $Log
#
#@export var player_scene: PackedScene
#
## Função chamada quando o cliente clica no botão "Join"
#func _on_botao_join_pressed() -> void:
	#var peer = ENetMultiplayerPeer.new()
	#var resposta = peer.create_client(ADDRESS, PORT)
	#multiplayer.multiplayer_peer = peer
	#multiplayer.connected_to_server.connect(on_connect_to_server)
#
	#if resposta == OK:
		#print("Conectado com sucesso!")
		#log.text += "Conectado com sucesso! \n"
		#on_connect_to_server()  # Quando a conexão for estabelecida, chamar a função para adicionar o jogador
#
	#else:
		#print("Ocorreu um problema ao se conectar: ", resposta)
		#log.text += "Ocorreu um problema ao se conectar: " + str(resposta) + "\n"
#
## Função chamada quando o cliente clica no botão "Host"
#func _on_botao_host_pressed() -> void:
	#var resposta = peer.create_server(PORT)
	#multiplayer.multiplayer_peer = peer
	#multiplayer.peer_connected.connect(jogador_conectado)
	#if resposta == OK:
		#print("Servidor criado com sucesso!")
		#log.text += "Servidor criado com sucesso! \n"
		#jogador_conectado(1)  
		#adicionar_jogador(1)  # Adiciona o primeiro jogador ao servidor
	#else:
		#print("Ocorreu um problema ao criar servidor: ", resposta)
		#log.text += "Ocorreu um problema ao criar servidor: " + str(resposta) + "\n"
#
## Função chamada quando um jogador se conecta ao servidor
#func jogador_conectado(id_jogador):
	#log.text += "O jogador " + str(id_jogador) + " acabou de se conectar! \n"
	#rpc("atualizar_chat", log.text)
#
#@rpc("any_peer", "call_local", "reliable")
#func atualizar_chat(novo_texto):
	#log.text = novo_texto
#
## Função para adicionar um jogador na cena (só executada no servidor)
#@rpc("any_peer")
#func adicionar_jogador(id_jogador):
	#if multiplayer.is_server():  # Garantir que apenas o servidor pode adicionar jogadores
		#var jogador = player_scene.instantiate()
		#add_child(jogador)
		## Sincroniza o nome do jogador, se necessário
#
## Função chamada quando o cliente se conecta ao servidor
#func on_connect_to_server():
	## O servidor é quem deve adicionar jogadores, não os clientes
	#if multiplayer.is_server():
		#rpc_id(1, "adicionar_jogador", multiplayer.get_unique_id())  # Chama o servidor para adicionar o jogador



extends Node2D

var peer = ENetMultiplayerPeer.new()
const ADDRESS = "127.0.0.1"
const PORT =  3333
@onready var log = $Control/Log
@onready var ui = $UIMultiplayer
@export var jogador_scene : PackedScene

#Exibir mensagem quando o servidor for criado e exibir mensagens sempre que
#um usuário se conectar
#Esconder menu de Multiplayer ao se conectar ou criar servidor com sucesso

#Na função de join, identificar se o jogador conseguiu se conectar. Se não conseguir
#exibir no log "Falha ao conectar ao servidor"
func _on_botao_join_pressed() -> void:
	var resultado = peer.create_client(ADDRESS, PORT)
	
	if resultado == OK:
		multiplayer.multiplayer_peer = peer
		log.text += "Conectado ao servidor! \n"
		ui.visible = false
	else:
		log.text += "Não foi possivel se conectar! Erro: "+str(resultado)+"\n"


func _on_botao_host_pressed() -> void:
	var resultado = peer.create_server(PORT)
	
	if resultado == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(player_conectado)
		log.text += "Servidor criado na porta "+str(PORT)+"!\n"
		ui.visible = false
		#criar personagem
		adicionar_jogador(multiplayer.get_unique_id())
	
	else:
		log.text += "Erro ao criar servidor! Código do erro: "+str(resultado) +"\n"
		
	
#Na função player_conectado realizar uma chamada rpc, para a função atualizar_log
#Deve rodar o adicionar_jogador
#Colocar um label no player para exibir o seu número de id
func player_conectado(id_jogador):
	log.text += "Cliente "+str(id_jogador)+" conectado ao servidor!\n"
	#Chamada rpc aqui
	rpc("atualizar_log", log.text)
	adicionar_jogador(id_jogador)
	
func adicionar_jogador(id_jogador):
	var novo_jogador = jogador_scene.instantiate()
	novo_jogador.name = str(id_jogador) 
	add_child(novo_jogador)
	
#Criar a função atualizar_log em que recebe o log.text do servidor e modifica o próprio log
@rpc("any_peer", "call_local", "reliable")
func atualizar_log(novo_log):
	log.text = novo_log
