extends Node

var peer = ENetMultiplayerPeer.new()
var ADDRESS = "127.0.0.1"
var PORT = 3000
var personagemEscolhido = 0
var nickJogador = ""
var jogadores = {}
var criarJogador = 0


func criar_servidor(personagem, nick):
	var resultado = peer.create_server(PORT)
	if (resultado == OK):
		multiplayer.multiplayer_peer = peer
		personagemEscolhido = personagem
		nickJogador = nick
		jogadores[multiplayer.get_unique_id()] = {}
		jogadores[multiplayer.get_unique_id()]["nick"] = nickJogador
		jogadores[multiplayer.get_unique_id()]["personagem"] = personagemEscolhido
		
		return OK
	else:
		return FAILED


func entrar_servidor(personagem, nick):
	var resultado = peer.create_client(ADDRESS, PORT)
	if (resultado == OK):
		multiplayer.multiplayer_peer = peer
		multiplayer.connected_to_server.connect(mandarInformacoesServidor)
		personagemEscolhido = personagem
		nickJogador = nick
		return OK
	else:
		return FAILED
		
func mandarInformacoesServidor():
	rpc_id(1, "armazenarNovoJogador", nickJogador, personagemEscolhido)

@rpc("any_peer","call_remote", "reliable")
func armazenarNovoJogador(nick, personagem):
	jogadores[multiplayer.get_remote_sender_id()] = {}
	jogadores[multiplayer.get_remote_sender_id()]["nick"] = nick
	jogadores[multiplayer.get_remote_sender_id()]["personagem"] = personagem

	print("Jogador Conectado", jogadores[multiplayer.get_remote_sender_id()])
	criarJogador = multiplayer.get_remote_sender_id()
