extends CharacterBody3D

## When we are in client mode we aren't directly controlling our character using
## move_and_slide on the local machine. Instead, we forward inputs to the server,
## and ther server tells us where to go. This means we need a different set of
## code for multiplayer server/client games than we do for local singleplayer.
## The Godot way to do this is to use the same script for all of those, and use
## conditional branching to run different logic depending on context. This seems
## counter intuitive to me, but I am new to this and Godot is amazing so we're
## not going to rock the boat on this one. We will, however, break code out into
## components so we can at least keep concerns separate, and we'll call down into
## those components from this script, rather than bloat it all with conditionals.
class_name MultiplayerCharacter

## the id assigned to us by Godot's multiplayer API - 1 is always the server
var player_id: int = 1
