extends Control

@onready var botaoFoxy = $Panel/BotaoFoxy
@onready var animacaoFoxy = $Panel/BotaoFoxy/AnimatedSprite2D
@onready var botaoSunny = $Panel/BotaoSunny
@onready var animacaoSunny = $Panel/BotaoSunny/AnimatedSprite2D
@onready var campoNome = $Panel/CampoNome

var personagemSelecionado = 0

func _on_botao_foxy_mouse_entered() -> void:
	if (personagemSelecionado != 2):
		animacaoFoxy.play("run")


func _on_botao_foxy_mouse_exited() -> void:
	if (personagemSelecionado != 2):
		animacaoFoxy.play("idle")

func _on_botao_foxy_pressed() -> void:
	personagemSelecionado = 2
	botaoFoxy.add_theme_color_override("font_color", Color(255,255,0))
	botaoFoxy.add_theme_color_override("font_hover_color",Color(255,255,0))
	botaoFoxy.add_theme_color_override("font_focus_color",Color(255,255,0))
	
	if (botaoSunny.has_theme_color_override("font_color")):
		botaoSunny.remove_theme_color_override("font_hover_color")
		botaoSunny.remove_theme_color_override("font_focus_color")
		botaoSunny.remove_theme_color_override("font_color")
	
	animacaoFoxy.play("run")
	animacaoSunny.play("idle")


func _on_botao_sunny_mouse_entered() -> void:
	if (personagemSelecionado != 1):
		animacaoSunny.play("run")


func _on_botao_sunny_mouse_exited() -> void:
	if (personagemSelecionado != 1):
		animacaoSunny.play("idle")


func _on_botao_sunny_pressed() -> void:
	personagemSelecionado = 1
	botaoSunny.add_theme_color_override("font_color", Color(255,255,0))
	botaoSunny.add_theme_color_override("font_hover_color",Color(255,255,0))
	botaoSunny.add_theme_color_override("font_focus_color",Color(255,255,0))
	if (botaoFoxy.has_theme_color_override("font_color")):
		botaoFoxy.remove_theme_color_override("font_hover_color")
		botaoFoxy.remove_theme_color_override("font_focus_color")
		botaoFoxy.remove_theme_color_override("font_color")
	animacaoSunny.play("run")
	animacaoFoxy.play("idle")
