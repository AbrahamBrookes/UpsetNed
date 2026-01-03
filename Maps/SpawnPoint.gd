extends Node3D

## A SpawnPoint is a node that spawns players. This is just to have a type-safe
## node for spawning players
class_name SpawnPoint

## A spawn point wraps a MultiplayerSpawner to hook into Godot's replication
@export var spawner: MultiplayerSpawner
