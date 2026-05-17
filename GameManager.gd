extends Node

var last_scene_path: String = ""

var total_minigames := 6
var minigames_completos := 0
var minigames_concluidos := {}

func completar_minigame(id: String):
	if minigames_concluidos.has(id):
		return # evita contar duas vezes
	
	minigames_concluidos[id] = true
	minigames_completos += 1
	
	print("Progresso: ", minigames_completos, "/", total_minigames)

	if minigames_completos >= total_minigames:
		todos_completos()

func todos_completos():
	get_tree().change_scene_to_file("res://screens/textos/finalfinal/finalfinal.tscn") # MUDA AQUI IGOR, PFV LEIA ESSE COMENTARIO!!!!
