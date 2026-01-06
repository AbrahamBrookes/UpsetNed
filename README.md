# Upset Ned
## Combat Status: Limbo

Shooty bang bang

![session 1](./Media/jump-slide-dive-shoot.gif)
![session 2](./Media/wall-flip.gif)
![Session 5](./Media/jacket-backflip.gif)
![Session 8](./Media/mp-server-connected.gif)
![Session 9](./Media/mp-server-movement.gif)

## Multiplayer scaffolding
The way Godot does multiplayer is super streamlined but it feels clunky to me. It seems to force you into a lot of conditionals throughout your code to check if you are on the server or on the client. Or maybe I just don't really understand the authority server pattern that much yet. In any case, this game is multiplayer and I want to have a clear separation between the dedicated server running on a ubuntu box somewhere and the client running on an end users computer.

I also want to have a server browser eventually, and I want the server to tell the client which map to load when it connects. I also want to isolate the RPC calls as much as I can so that the conditionals for ie `multiplayer.is_server()` are as far away from the application code as I can get them. For all these reasons I am trying out a bootstrapping system thus:

### Main.tscn
This is the entrypoint for the application, and exists for the life of the session. It has a mount point for us to load maps onto, and contains some nodes to assist in the bootstrapping and connecting of servers and clients.

### ServerBootstrapper.gd
When Main.gd sees it is operating in headless mode, it calls ServerBootstrapper.boot. This requires a --map launch arg which tells the server which map to load.

### ClientBootstrapper.gd
When Main.gd sees that it is _not_ in headless mode, it routes the player to the main menu. The user can join a server using a server browser (eventually) and the ClientBootstrapper then connects to that server.

### Network.gd
When the client connects to a server, the server tells the client to load the map. This is done via an RPC call and that RPC call lives in Network.gd. The idea is that, since Godot requires RPC methods to exist on both the server and the client, the Network script will be the central place that mediates all those calls.

I'm hoping this system will give us a bunch of advantages, namely:
 - Allowing servers to tell clients which map to load
 - Allowing servers to tell clients to load community-created maps using ResourceLoader and .pck files
 - Encouraging devs (me) to separate out networky stuff from shooty stuff