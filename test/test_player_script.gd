extends GutTest

var Scene = preload("res://scenes/testing_scene/test.tscn")
var scene
var player
var sender


func before_each() -> void:
	scene = Scene.instantiate()
	player = scene.get_node("Player")
	sender = InputSender.new(player)
	add_child(scene)
	scene.get_tree().process_frame


func after_each() -> void:
	player.queue_free()
	scene.queue_free()
	sender.release_all()
	sender.clear()


func test_tapping_left_certain_distance():
	sender.action_down("left").hold_for(.5).wait(.3)
	await(sender.idle)
	assert_between(player.position.x, 312.0, 334.0)


func test_when_uai_enabled_just_pressed_is_not_processed_immediately():
	sender.action_down('left')
	assert_false(Input.is_action_just_pressed('left'))


func test_when_uai_enabled_waiting_makes_button_pressed():
	# wait 10 frames.  In testing, 6 frames failed, but 7 passed.  Added 3 for
	# good measure.
	sender.key_down(KEY_A).wait('10f')
	assert_true(sender.is_key_pressed(KEY_A))


func test_when_uai_enabled_flushig_buffer_sends_input_immediatly():
	sender.key_down('a')
	Input.flush_buffered_events()
	assert_true(sender.is_key_pressed(KEY_A))


func test_when_uai_enabled_flushing_buffer_just_pressed_is_processed_immediately():
	sender.action_down('left')
	Input.flush_buffered_events()
	assert_true(sender.is_key_pressed(KEY_A))


func test_disabling_uai_sends_input_immediately():
	Input.use_accumulated_input = false
	sender.key_down('a')
	assert_true(sender.is_key_pressed(KEY_A))
	# re-enable so we don't ruin other tests
	Input.use_accumulated_input = true
