extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -200.0
const WALL_JUMP_FORCE = Vector2(150,-250)

@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_effect_timer: Timer = $DashEffectTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

@onready var j: CharacterBody2D = $"."

@onready var animated_sprite = $JOHNGUY

var jumpcount = 0
var dashcount = 0
var wallDirection = 0
var vertLookDirection = 0
var lookDirection = 0
var isDashing = false
var canDash = true
var isVertDashing = false
var dashSpeed = 2
var direction = 0
var double_jumps = 0
var coyote = 0
var vmax_x = 200
var is_wall_sliding = false
var friction_y = 100
var vertDirection = 0

func animate():
	if (velocity.x == 0 and velocity.y == 0 and !Input.is_action_pressed("down") and !isDashing):
		animated_sprite.play("idle")
		
	if (velocity.y < 0 and double_jumps < 1 and !isDashing):
		animated_sprite.play("jump")
		
	if (velocity.y > 0 and !isDashing):
		animated_sprite.play("fall")
		
	if ((velocity.x < 0 or velocity.x > 0) and (velocity.y == 0) and !isDashing):
		animated_sprite.play("walk")
		
	if (Input.is_action_pressed("down") and (velocity.y == 0) and !isDashing):
		animated_sprite.play("crouch")
		
	if (velocity.y <= 0 and double_jumps > 0 and !isDashing):
		animated_sprite.play("double_jump")
		
	if (is_wall_sliding and !isDashing):
		animated_sprite.play("wall_slide")
		
	elif isDashing and velocity.y != 0:
		animated_sprite.play("walk_dash")
	elif velocity.y < 0 and canDash == false:
		animated_sprite.play("dash_jump")
	elif velocity.y == 0 and canDash == false:
		animated_sprite.play("dash")
	elif velocity.y > 0 and canDash == false:
		animated_sprite.play("fall_dash")
	



func limiter():
	if (Input.is_action_just_pressed("jump")):
		jumpcount = 1
	if (Input.is_action_just_released("jump")):
		jumpcount = 0
	if (Input.is_action_just_pressed("dash")):
		dashcount = 1
	if (Input.is_action_just_released("dash")):
		dashcount = 0

func get_direction():
	direction = Input.get_axis("left", "right")
	if direction > 0:
		lookDirection = 1
		animated_sprite.flip_h = false
	if direction < 0:
		lookDirection = -1
		animated_sprite.flip_h = true

func get_vertDirection():
	vertDirection = Input.get_axis("up", "down")
	if vertDirection > 0:
		vertLookDirection = 1
	elif vertDirection < 0:
		vertLookDirection = -1
	else:
		vertLookDirection = 0

func jump_thru():
	if(Input.is_action_pressed("down")):
		set_collision_mask_value(3,false)
	else:
		set_collision_mask_value(3,true)

func DoubleJump():
	if((not is_on_floor()) and not isDashing and double_jumps < 1 and Input.is_action_just_pressed("jump")):
		velocity.y = JUMP_VELOCITY-100
		double_jumps += 1
	elif (is_on_floor()):
		double_jumps = 0
	
func wall_slide():
	if(is_on_wall() and !is_on_floor() and velocity.y != 0):
		is_wall_sliding = true
		double_jumps = 1
		if get_wall_normal().x > 0:
			wallDirection = 1
		elif get_wall_normal().x < 0:
			wallDirection = -1
		velocity.y = move_toward(velocity.y, friction_y, 20)
		if is_wall_sliding == true and Input.is_action_just_pressed("jump"):
			if isDashing:
				velocity.y = WALL_JUMP_FORCE.y * dashSpeed
			velocity.x = wallDirection * WALL_JUMP_FORCE.x
			velocity.y = WALL_JUMP_FORCE.y
			double_jumps = 0
			is_wall_sliding = false
	else:
		is_wall_sliding = false

func dash():
	if (Input.is_action_pressed("dash") and canDash and dashcount != 1):
		isDashing = true
		canDash = false
		dash_effect_timer.start()
		dash_duration_timer.start()
		dash_cooldown_timer.start()
	if isDashing and not Input.is_action_pressed("jump") and not is_on_floor() and not is_on_wall() and vertLookDirection == 0:
		velocity.x = lookDirection * SPEED * dashSpeed
		velocity.y = 0
	
	elif isDashing and vertLookDirection == 0:
		isVertDashing = true
		velocity.x = lookDirection * SPEED * dashSpeed
		
		
	elif isDashing and vertLookDirection != 0:
		isVertDashing = true
		velocity.y = vertLookDirection * SPEED * dashSpeed
		
		
	if ((is_on_floor() or is_on_wall()) and $DashCooldownTimer.is_stopped()):
		canDash = true

func respawn():
	self.global_position = Vector2(441,89)

func _physics_process(delta: float) -> void:
	
	dash()
	limiter()
	animate()
	DoubleJump()
	jump(delta)
	walk()
	move_and_slide()
	
	if (isDashing == false):
		add_grav(delta)
	wall_slide()
	if (isDashing == false):
		jump_thru()
		get_vertDirection()
		get_direction()
		
	
	
	
func add_grav(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
func jump(delta):
	# Handle jump.
	if is_on_floor() and jumpcount != 1:
		coyote = 0
	else:
		coyote += delta
	if Input.is_action_pressed("jump") and coyote < (7.0/30.0):
		velocity.y = JUMP_VELOCITY
		
func walk():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction and abs(velocity.x) < vmax_x:
		velocity.x += direction * 7.5
	else:
		velocity.x = move_toward(velocity.x, 0, 15)
		
		
		
func _on_dash_duration_timer_timeout() -> void:
	isDashing = false
	isVertDashing = false
	dash_effect_timer.stop()
	#animated_sprite.play("dash_replenish")
	


func _on_hurtbox_body_entered(body: Node2D) -> void:
	j.respawn()



	




func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("BALLER")
	if body.name == "RigidBody2D":
		print("HELLO")
		get_tree().change_scene_to_file("res://END.tscn")
		
