# res://Enemies/States
These States are used by enemies in the game. 

## States and Behaviour Trees
Generally a state controls the current behavour of an actor doing a task. In order to decide what to do _next_, each state in the state machine may have a behavour tree, and the state itself handles ticking it's own behaviour tree, in order to advance to the next state.

Because we have multiple behaviour trees, but we will likely want to reuse paths (ie "can I see the player -> go to pursue"), create your behaviour tree paths in scenes and then we can put those scenes into each state's behaviour tree in order to reuse the logic and have a central place to update it everywhere.
