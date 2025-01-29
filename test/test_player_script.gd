extends GutTest

var Scene = preload("res://scenes/testing_scene/test.tscn")
var scene
var player
var _sender = InputSender.new(Input)


func before_each() -> void:
	scene = add_child_autofree(Scene.instantiate())
	player = add_child_autofree(scene.get_node("Player"))
	scene.get_tree().process_frame


func after_each() -> void:
	scene.queue_free()
	player.queue_free()
	_sender.release_all()
	_sender.clear()


func test_when_uai_enabled_input_not_processed_immediately():
	_sender.key_down('a')
	assert_false(Input.is_key_pressed(KEY_A))

func test_when_uai_enabled_just_pressed_is_not_processed_immediately():
	_sender.action_down('left')
	assert_false(Input.is_action_just_pressed('left'))

func test_when_uai_enabled_waiting_makes_button_pressed():
	# wait 10 frames.  In testing, 6 frames failed, but 7 passed. 
	# Added 3 for good measure.
	_sender.key_down(KEY_A).wait('10f')
	await(_sender.idle)
	assert_true(_sender.is_key_pressed(KEY_A))
	assert_true(Input.is_key_pressed(KEY_A))

func test_when_uai_enabled_flushig_buffer_sends_input_immediatly():
	_sender.key_down('a')
	Input.flush_buffered_events()
	assert_true(Input.is_key_pressed(KEY_A))

func test_disabling_uai_sends_input_immediately():
	Input.use_accumulated_input = false
	_sender.key_down('a')
	assert_true(Input.is_key_pressed(KEY_A))
	# re-enable so we don't ruin other tests
	Input.use_accumulated_input = true

func test_when_uai_enabled_flushing_buffer_just_pressed_is_processed_immediately():
	_sender.action_down('left')
	Input.flush_buffered_events()
	assert_true(Input.is_action_just_pressed('left'))
	
# In this test we press and hold the left button for .3 seconds then wait
# another .3 seconds for the left to take take place.  We then assert that
# the character has moved left between 15 and 18 pixels.
func test_tapping_left_changes_certain_lenght():
	#var player = add_child_autofree(Player.new())
	_sender.action_down("left").hold_for(.3).wait(.3)
	await(_sender.idle)
	assert_between(player.position.x, 315.0, 333.0)
	
func test_tapping_right_changes_certain_lenght():
	#var player = add_child_autofree(Player.new())
	_sender.action_down("right").hold_for(.3).wait(.3)
	await(_sender.idle)
	assert_between(player.position.x, 334.0, 365.0)
