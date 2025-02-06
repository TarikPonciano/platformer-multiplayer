extends Node2D

# 1. Criar interface com botões
# Host e Join.

# 2. Criar a infraestrutura de
# conexão desses botões. 
# Código de Join Server
# Código de Create Server

# 3. Exibir informação na tela ou
# terminal, quando um usuário se 
# conectar.
var peer = ENetMultiplayerPeer.new()
const ADDRESS = "127.0.0.1"
const PORT = 3333
@onready var log = $Log

# Rodar o create_client
# Alterar o multiplayer godot para ser o peer
func _on_botao_join_pressed() -> void:
	var resposta = peer.create_client(ADDRESS,PORT)
	multiplayer.multiplayer_peer = peer
	if resposta == OK:
		print("Conectado com sucesso!")
		log.text += "Conectado com sucesso! \n"
	else:
		print("Ocorreu um problema ao se conectar: ",resposta)
		log.text += "Ocorreu um problema ao se conectar: "+str(resposta)+"\n"
	
# Rodar o create_server
# Alterar o multiplayer godot para ser o peer
func _on_botao_host_pressed() -> void:
	var resposta = peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(jogador_conectado)
	if resposta == OK:
		print("Servidor criado com sucesso!")
		log.text += "Servidor criado com sucesso! \n"
		jogador_conectado(1)
	else:
		print("Ocorreu um problema ao criar servidor: ",resposta)
		log.text += "Ocorreu um problema ao criar servidor: "+str(resposta)+"\n"
	
#Vai acontecer somente no servidor, pois não há chamadas em outra situação
func jogador_conectado(id_jogador):
	log.text += "O jogador "+str(id_jogador)+" acabou de se conectar! \n"
	rpc("atualizar_chat", log.text)
	
@rpc("any_peer", "call_local","reliable")
func atualizar_chat(novo_texto):
	log.text = novo_texto
	
