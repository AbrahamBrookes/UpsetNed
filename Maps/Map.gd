extends Node3D

## The Map script is attached to the root node of our Map scenes and handles
## map-level stuff like choosing which spawn point to spawn a player into.
class_name Map

## the list of spawn points in the map, for spawning players
@export var spawn_points: Array[SpawnPoint]

## the server view camera that the player goes to when their own camera is destroyed
@export var server_camera: Camera3D
