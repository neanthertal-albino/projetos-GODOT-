extends CharacterBody2D

#variaveis
var grav = 15  #grav: valor da gravidade do player
var speed = 350  #speed: valor da velocidade do player (o tanto q ele anda)
var tim_o_meter = 0.0  #tim_o_meter: ele é só um contador (anteriormente eu pensei nele como um controle pro player poder escolher a altura em q pulasse, só q dai ele aumentou o pulo de um outra forma (o segundo pulo fica maior se ficar segurando K), gostei e deixei no jogo mesmo :D)
var tim_coyote = 0.0  #tim_coyote: ele é basicamente o mesmo q o "tim_o_meter", só q ele funciona para quando ele estiver caindo ter um atraso antes de cair (igual o coyote do desenho do papaléguas, bep bep!) e tambem da pra controlar a altura do pulo.
var is_falling = false  #is_falling: isso apenas mostra pro código se o player pulou ou nao
var jumped = false  #jumped: mesma coisa do "falling", só q ele mostra se o player pulou.
var ass_powered = false  #ass_powered: mostra se o player deu um "ASS POWER!!!".
var couldown_ass_power = 5.0  #couldown_ass_power: ele é o tempo em q o player fica parado após o "ASS POWER!!!".
var shake_strength = 0.0  #forca do shake (shake = tremer pros bot dos ingreis haha)
var contador_shake = 0.0  #conta quando o shake pode ou nao acontecer
var permetidor_shake = false  #permite ou nao o contador shake contar
var rezet_shake = false   #rezeta o contador shake
@onready var camera = $Camera2D  #é a camera
var pode_jumpwall = false  #ele permite se pode jumpwall ou nao
var contador_jumpwall = 0.0  #ele conta por quanto tempo o jumpwall ficara verdadeiro.
#var lookahead = 800  # distância à frente do player
#var target_x = 0
var stage_run = 0 # estagios de velocidade da corrida (de 0 a 2)
var conta_stage_run:int = 0 # tempo de cooldown entre os estagios
var plan = false # verifica se o player planou
var cont_vel_pstg = 0

#o "func _physics_process(_delta):" roda tudo oque tiver nele 60 vezes por segundo (muita coisa né?) 
func _physics_process(_delta: float) -> void:
	if is_on_floor() and !Input.is_key_label_pressed(KEY_A) and !Input.is_key_label_pressed(KEY_D):
		$AnimatedSprite2D.play("idle")
	#isso apenas mostra se o player está caindo ou nao, por ser tão curto eu deixei no proprio func process mesmo.
	if !is_on_floor():
		is_falling = true
		$AnimatedSprite2D.play("falll")
	else:
		is_falling = false
		plan = false
	#ja esse mostra se o player pulou ou nao. (tambem por ser muito curto deixei no func process).
	if jumped == true:
		if is_on_floor():
			jumped = false
	
	# Limita a velocidade vertical pra não explodir o pc
	if velocity.y >= 10000:
		velocity.y = 10000
		
	if global_position.y > 1000:  # ou qualquer valor fundo do seu mapa
		global_position = Vector2(160, 464)  # volta pro comeco
		velocity = Vector2.ZERO  # zera velocidade pra evitar bug de queda
	
	#aqui estao as funcoes que criei.
	_plane()
	
	_move_basics()
	
	_slide_run_wall()
	
	_ASS_POWER()
	
	_jump()
	
	_tim_meter(_delta)
	
	_tim_coyote(_delta)
	
	trigger_shake()
	
	camera_shake(_delta)
	
	jumpwall()
	
	_stage_run()
	
	cont_vel_pstgf()
	
	cooldown_run()
	
	#esse aqui é apenas um "comando" que faz as coisas realmente acontecerem.
	move_and_slide()

#esse aqui é a uma funcao q eu criei, é bem simples como da pra ver.
func _plane():
	#ao apertar e presionar "W" e nao tiver contato com paredes, o eixo y do player tera 70 adicionado na queda.
	#(faz planar)
	if Input.is_key_pressed(KEY_W) and !is_on_wall():
		velocity.y = 70
		plan = true
		#mas se apertar J e D o player irá planar mais rapidamente, ou seja. ele caira mais rapido.
		if Input.is_key_pressed(KEY_J) and Input.is_key_pressed(KEY_D):
			velocity.y = 150
			#aqui tambem, só que pra esquerda. 
		elif Input.is_key_pressed(KEY_J) and Input.is_key_pressed(KEY_A):
			velocity.y = 150

#esse aqui é a funcao "move basics" (que de basico nao tem nada).
func _move_basics():
	#se apertar D e o "coldown_ass_power" for 0, o eixo x sera igual o valor da variavel speed (o palyer anda).
	if Input.is_key_pressed(KEY_D):
		if !Input.is_key_pressed(KEY_S):
			if couldown_ass_power == 0:
				velocity.x = speed
				#isso só deixa o sprite do player pra direita.
				$AnimatedSprite2D.flip_h = false
				if is_on_floor():
					$AnimatedSprite2D.play("walk")
				#se apertar J junto e estiver no chao o player corre.
				if Input.is_key_pressed(KEY_J):
					if stage_run == 0: # estagios do 0 ao 2
						velocity.x += speed + 200
					elif stage_run == 1:
						velocity.x += speed + 500
					elif stage_run == 2:
						velocity.x += speed + 1000
				else:
					velocity.x = speed
		#se apertar S a velocidade para
		else:
			velocity.x = 0
	#isso é a mesa coisa, so q com o A (q dai é pra esquerda)
	elif Input.is_key_pressed(KEY_A):
		if !Input.is_key_pressed(KEY_S):
			if couldown_ass_power == 0:
				velocity.x = -speed
				$AnimatedSprite2D.flip_h = true
				if is_on_floor():
					$AnimatedSprite2D.play("walk")
				if Input.is_key_pressed(KEY_J):
					if stage_run == 0:
						velocity.x += -speed - 200
					elif stage_run == 1:
						velocity.x += -speed - 500
					elif stage_run == 2:
						velocity.x += -speed - 800
				else:
					velocity.x = - speed
		else:
			velocity.x = 0
	#e se nem o D ou A for apertado, o eixo X é igual a 0 (o player para).
	else:
		velocity.x = 0

#esse aqui é bem simples mesmo, ele faz o player deslizar, parar (S) e escalar a parede (se apertar J)                                                                                                                  (que agora eu nao sei o pq o player apenas deslisa mais devagar)
func _slide_run_wall():
	if is_on_wall() and !is_on_floor():
		velocity.y = 100
		if Input.is_key_pressed(KEY_S):
			velocity.y = -30
		if Input.is_key_pressed(KEY_J) and !Input.is_key_pressed(KEY_S):
			if stage_run == 0:
				velocity.y += - 800
			elif stage_run == 1:
				velocity.y += - 1400
			elif stage_run == 2:
				velocity.y += - 2000
			
			if Input.is_key_pressed(KEY_K):
				velocity.y +=  - 150
			if !is_on_wall():
				velocity.y += 200
	if velocity.y <= -800:
		velocity.y += 300
	
#essa funcao aqui faz com q o player de um "ground pound" no chao, mas eu prefiro chamar de ass power mesmo.
func _ASS_POWER():
	#se apertar S e NAO estiver no chao e NAO estiver apertando K o eixo x do player aumenta continuamente em 400.
	#(que faz ele cair bem rapido)
	if Input.is_key_label_pressed(KEY_S) and !is_on_floor() and !Input.is_key_label_pressed(KEY_K):
		if !is_on_wall():
			velocity.y += 400
			#e dai o "ass_powered" fica igual a true ("verdadeiro" pros nao bilingue, haha) e o couldown fica igual a 3.0
			ass_powered = true
			couldown_ass_power = 2.0
			permetidor_shake = true
	#e se tiver chego no chao o powered fica false ("falso" pros !bilingue, ha) e o contador comeca a diminuir 0.2
	elif is_on_floor():
		ass_powered = false
		couldown_ass_power -= 0.1
		shake_strength = 20
		if permetidor_shake == true:
			contador_shake += 0.1
		
		#dai se chegar a 0 ou menos (o ou menos eu coloquei so pra garantir q ele pare de diminuir mesmo) fica = 0
		if couldown_ass_power <= 0:
			couldown_ass_power = 0
	#se nenhum desses dois acontecer e apertar S mesmo assim o couldown fica = 0
	else:
		if !Input.is_key_label_pressed(KEY_S):
			couldown_ass_power = 0

#essa funcao aqui faz o player pular, da pra ver q nao é tao simples por ter "apenas" 24 linhas de codigo, nao é? (sim, eu contei a linhas. [na verdade só diminui 30 por 52 mesmo e {diminui 1 (no final eu so copiei e colei no inicio mesmo)}, mas isso nao interessa, volta pro código!!! D:< ]).
func _jump():
	#se estiver no chao e apertar K e NAO apertar W e nem S o eixo y diminue em 270 (faz o player pular)
	if is_on_floor():
		#se o coldown for menor ou igual a 0 o player po pular. 
		if couldown_ass_power <= 0:
			if Input.is_key_label_pressed(KEY_K) and !Input.is_key_label_pressed(KEY_W) and !Input.is_key_label_pressed(KEY_S):
				jumped = true
				velocity.y -= 300
				#e dae se o tim_o_meter (tempometro ou temporizador) for maior ou igual a 1 ele diminue 100... (aparentemente se eu tirar isso aqui ferra com o codigo, entao vou deixa-lo aqui)
				if tim_o_meter >= 1:
					velocity.y -= 100
					#se apertar K e o tim for igual ou maior a 2,vai diminuir 20 (fazendo o pulo ficar maior)
					if Input.is_key_pressed(KEY_K) and tim_o_meter >= 2:
						velocity.y -= 20
	#se nao estiver em contato com o chao...
	else:
		#...e se o "jumped" for false e o tim_coyote for menor ou igual a 1, o eixo y diminue em 100 
		if jumped == false:
			if tim_coyote <= 2:
				if Input.is_key_pressed(KEY_K):
					velocity.y -= 80
		#e se nao (q dai o jumped for true) o eixo y aumenta igual o valor de grav (o player cai)
		else:
			velocity.y += grav
		#...e se o jumped for true (oq ja ta acontecendo) e o tim_coyote for maior ou igual a 1 
		if jumped == true:
			if tim_coyote <= 1:
				#se tiver apertando K o eixo y diminuira 20 (aumentando o pulo, dando uma leve semelhanca ao yoshi do "mario world" [só leve...])
				if Input.is_key_pressed(KEY_K):
					velocity.y -= 10
		#se nao o player só cai mesmo
		else:
			if tim_coyote >= 2:
				velocity.y += grav
				

#esse é o tim, de um "oi" pro tim >:], ele é um temporizador.
func _tim_meter(_delta):
	#se o player estiver no chao o tim fica 0
	if is_on_floor():
		tim_o_meter = 0
	#dae se apertar K o tim comeca a contar 0.1
	if Input.is_key_pressed(KEY_K):
		tim_o_meter += 0.1
	#se o tim chegar a 5 ou for maior o tim volta a ser 0
	if tim_o_meter >= 5:
		tim_o_meter = 0

#esse é o coyote, infelismente ele nao fala... mas ainda vc pode dar um "oi" pra ele. :]
func _tim_coyote(_delta):
	#se estiver no chao o coyote é igual a 0
	if is_on_floor():
		tim_coyote = 0
	#se is_falling for = true (o player estiver caindo) o coyote comeca a contar 0.1
	if is_falling == true:
		tim_coyote += 0.1
		#se chegar ou for maior q 2 o eixo y é igual a grav (o player cai)
		if tim_coyote >= 2:
			velocity.y += grav

#esse aqui funciona bem simples se o contador shake for >= a 2, o permetidor fica falso. 
func trigger_shake():
	if contador_shake >= 2:
		permetidor_shake = false
	#e se o permetidor fica falso o contador fica 0 e a forca shake fica 0
	if permetidor_shake == false:
		contador_shake = 0
		shake_strength = 0

func camera_shake(_delta):
	#se nao tiver numa parede e nao tiver apertando K (resumidamente a camera chacoalha)
	if !is_on_wall():
		if  !Input.is_key_pressed(KEY_K):
			if shake_strength > 0:
				camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
				shake_strength = lerp(shake_strength, 0, _delta * 5)
			else:
				camera.offset = Vector2.ZERO

#ele é literalmente oq fala, ele pula das paredes.
func jumpwall():
	#se encostar na parede o pode_jumpwall fica verdadeiro
	if is_on_wall():
		pode_jumpwall = true
	#e se fica verdadeiro e apertar K e...
	if pode_jumpwall == true:
		#ele da um (pulo do ar)
		if Input.is_key_pressed(KEY_K) and !is_on_wall():
			velocity.y -= 150
			#e se nao estiver na parede o contador jumpwall comeca a contar.
			if !is_on_wall():
				contador_jumpwall += 0.1
			#se aperta A durante tudo isso o player dara uma investida pra esquerda.
			if Input.is_key_pressed(KEY_A):
				velocity.x += -400
			#se aperta D durante tudo isso o player dara uma investida pra direita.
			if Input.is_key_pressed(KEY_D):
				velocity.x += 400
		elif Input.is_key_pressed(KEY_K) and is_on_wall():
			contador_jumpwall = -0.5
	#se estiver o chao o pode jumpwall fica falso
	if is_on_floor():
		pode_jumpwall = false
	#se o contador for maior q 0.5 o pode jumpwall fica falso
	if contador_jumpwall >= 1:
		pode_jumpwall = false
	#se o pode jumpwall for falso o contador rezeta.
	if pode_jumpwall == false:
		contador_jumpwall = 0

# func _camera():
	# theres nothing to the beta...
	
func _stage_run():
	if cont_vel_pstg == 0:
		if Input.is_key_label_pressed(KEY_J) and plan == false:
			conta_stage_run +=  1
			velocity0()
			if conta_stage_run >= 150 and conta_stage_run < 350:
				stage_run = 1
				velocity0()
			elif conta_stage_run >= 600:
				stage_run = 2
				conta_stage_run = 600
				velocity0()
		else:
			conta_stage_run = 0
			stage_run = 0
	else:
		conta_stage_run = 0
		stage_run = 0
		

func cont_vel_pstgf():
	if Input.is_key_label_pressed(KEY_J):
		if velocity.x == 0:
			cont_vel_pstg += 0.1
			if cont_vel_pstg == 0.1:
				cont_vel_pstg = 0.1
		else:
			cont_vel_pstg = 0
	else:
		cont_vel_pstg = 0

func velocity0():
	if velocity.x == 0:
		conta_stage_run = 0
		stage_run = 0

func cooldown_run():
	print('banana')
	#if velocity.x > 900:
		
