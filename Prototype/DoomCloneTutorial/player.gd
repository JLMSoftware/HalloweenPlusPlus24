extends CharacterBody3D
@onready var anim_sprite = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var raycast_3D = $RayCast3D
@onready var shoot_sound = $ShootSound


const SPEED = 5.0
const MOUSE_SENS = 0.5

var can_shoot = true
var dead = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	anim_sprite.animation_finished.connect(shoot_anim_done)
	$CanvasLayer/DeathScreen/Panel/Button.button_up.connect(restart)
	
func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
		
		
	if dead:
		return
		
	if Input.is_action_just_pressed("shoot"):
		shoot()



func _physics_process(delta):
	if dead:
		return
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func restart():
	get_tree().reload_current_scene()
	
func shoot():
	if !can_shoot:
		return
	can_shoot = false
	anim_sprite.play("shoot")
	shoot_sound.play()
	if raycast_3D.is_colliding() and raycast_3D.get_collider().has_method("kill"):
		raycast_3D.get_collider().kill()

func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
