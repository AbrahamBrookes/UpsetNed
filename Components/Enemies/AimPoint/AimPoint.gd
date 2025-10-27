extends Node

class_name AimPoint

## Have a look at MouseLook. That Script handles setting blend spaces in the animation tree for the
## player character, so that our dodgy animation pointy rig up thing makes it look like the player
## is pointing where the camera is looking. Enemies use the same rig and animation tree, but they
## don't have a human manipulating a camera, so we don't have anything to get our angles from.
