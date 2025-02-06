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

# Rodar o create_client
# Alterar o multiplayer godot para ser o peer
func _on_botao_join_pressed() -> void:
	peer.create_client(ADDRESS,PORT)
	multiplayer.multiplayer_peer = peer
	
# Rodar o create_server
# Alterar o multiplayer godot para ser o peer
func _on_botao_host_pressed() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
