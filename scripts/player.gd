extends KinematicBody2D

const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

export (int) var speed
export (int) var max_speed
export (int) var jump_speed
export (Vector2) var wall_jump

export (Vector2) var gravity

var hanging = null

var velocity = Vector2()

func _physics_process(delta):
    if hanging:
        velocity += gravity / 16
        if Input.is_action_just_pressed("ui_up"):
            $Particles2D.emitting = true
            velocity = hanging * wall_jump + UP * wall_jump
            hanging = null
    else:
        velocity += gravity
        if Input.is_action_pressed("ui_right"):
            velocity += RIGHT * speed
        if Input.is_action_pressed("ui_left"):
            velocity += LEFT * speed
        if is_on_floor() and Input.is_action_pressed("ui_up"):
            $Particles2D.emitting = true
            velocity += UP * jump_speed
            
        if velocity.x > max_speed:
            velocity.x = max_speed
        if velocity.x < -max_speed:
            velocity.x = -max_speed
        
    if velocity.y > 0:
        $Particles2D.emitting = false

    velocity = move_and_slide(velocity, UP)

    for collision_index in range(0, get_slide_count()):
        var collision = get_slide_collision(collision_index)
        if collision.collider.is_class("TileMap"):
            var tile_map = collision.collider
            var tile = tile_map.world_to_map(collision.position)
            if tile_map.get_cellv(tile) == 1 and collision.normal == DOWN:
                tile_map.set_cellv(tile, -1)
                
            if collision.normal == LEFT and not is_on_floor():
                $HangTimer.start()
                hanging = LEFT
                velocity = Vector2()
                
            if collision.normal == RIGHT and not is_on_floor():
                $HangTimer.start()
                hanging = RIGHT
                velocity = Vector2()
                

func _on_HangTimer_timeout():
    hanging = null
