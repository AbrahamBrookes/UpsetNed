extends GutTest

var main_script = preload("res://Main.gd")

# the objects we are testing with
var main: Main
var mock_display_server
var mock_server_bootstrapper: ServerBootstrapper
var mock_client_bootstrapper: ClientBootstrapper

class MockServerBootstrapper:
	extends ServerBootstrapper
	var boot_called = false
	func boot():
		boot_called = true

class MockClientBootstrapper:
	extends ClientBootstrapper
	var boot_called = false
	func boot():
		boot_called = true

class MockDisplayServer:
	var name = ""
	func get_name():
		return name

# inject our mocks before each test
func before_each():
	# construct the main object
	main = autoqfree(main_script.new())

	# inject our mock display server
	mock_display_server = MockDisplayServer.new()
	main.display_server_provider = mock_display_server

	# inject our mock bootstrappers
	mock_server_bootstrapper = autoqfree(MockServerBootstrapper.new())
	main.server_bootstrapper = mock_server_bootstrapper
	mock_client_bootstrapper = autoqfree(MockClientBootstrapper.new())
	main.client_bootstrapper = mock_client_bootstrapper


# test our running_as_server helper returns true when display server reports headless
func test_running_as_server_returns_true_when_headless():
	# fudge our display server to report headless
	mock_display_server.name = "headless"
	assert_true(main.running_as_server())

# test our running_as_server helper returns false when display server reports not headless
func test_running_as_server_returns_false_when_not_headless():
	# fudge our display server to report not headless
	mock_display_server.name = "windows"
	assert_false(main.running_as_server())

# test that in headless mode we bootstrap the server
func test_bootstrap_server_calls_server_bootstrapper():
	# fudge our display server to report headless
	mock_display_server.name = "headless"
	
	# ready up
	main._ready()
	assert_true(mock_server_bootstrapper.boot_called)

# test that in non headless mode we bootstrap the client
func test_bootstrap_client_calls_client_bootstrapper():
	# fudge our display server to report not headless
	mock_display_server.name = "windows"
	
	# ready up
	main._ready()
	assert_true(mock_client_bootstrapper.boot_called)
