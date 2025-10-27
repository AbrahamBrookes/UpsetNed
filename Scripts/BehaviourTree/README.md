# Behavior Tree System

## Overview

This is a behavior tree system for AI agents in Godot. Behavior trees are a hierarchical way to create complex AI behaviors by composing simple, reusable nodes together. Unlike state machines, behavior trees excel at handling complex decision-making with multiple conditions and priorities.

**When to use Behavior Trees:**
- Complex enemy AI with multiple behaviors and priorities
- AI that needs to evaluate many conditions simultaneously
- Reusable AI components across different enemy types
- Designer-friendly visual AI editing

## Core Concepts

### Status Types
Every node returns one of three states:
- `SUCCESS`: Task completed successfully
- `FAILURE`: Task failed and cannot be completed
- `RUNNING`: Task is in progress, continue next frame

### Node Types

#### Composite Nodes (Control Flow)
- **Selector (OR logic)**: Tries children until one succeeds
- **Sequence (AND logic)**: All children must succeed in order

#### Leaf Nodes (Actions & Conditions)
- **Condition**: Checks if something is true/false
- **Action**: Performs a task (may take multiple frames)

### Blackboard
A shared dictionary that all nodes can read from and write to. Use it to share data between nodes without tight coupling.

## Quick Start

### 1. Scene Setup
```
Enemy (CharacterBody3D)
├── BehaviourTree
│   └── BehaviourTreeSelector (root)
│       ├── BehaviourTreeSequence (high priority branch)
│       │   ├── CurrentTargetInRangeCondition
│       │   └── AttackPlayerAction
│       ├── BehaviourTreeSequence (medium priority branch)
│       │   ├── PlayerVisibleCondition
│       │   └── ChasePlayerAction
│       └── PatrolAction (low priority fallback)
├── CollisionShape3D
├── MeshInstance3D
└── AnimationTree
```

### 2. Enemy Script
```gdscript
extends CharacterBody3D

@onready var behavior_tree: BehaviourTree = $BehaviourTree
@export var player: Node3D

func _ready():
    # Initialize blackboard with shared data
    behavior_tree.set_blackboard_value("player", player)
    behavior_tree.set_blackboard_value("attack_range", 2.0)
    behavior_tree.set_blackboard_value("detection_range", 8.0)

func _physics_process(_delta):
    # Update blackboard with current state
    if player:
        var distance = global_position.distance_to(player.global_position)
        behavior_tree.set_blackboard_value("player_distance", distance)
```

### 3. Create Custom Conditions
```gdscript
extends BehaviourTreeCondition
class_name CurrentTargetInRangeCondition

@export var range_key: String = "attack_range"

func tick(blackboard: BehaviourTreeBlackboard) -> int:
    var player_distance = blackboard.get("player_distance", INF)
    var attack_range = blackboard.get(range_key, 2.0)
    
    if player_distance <= attack_range:
        return BehaviourTreeResult.Status.SUCCESS
    else:
        return BehaviourTreeResult.Status.FAILURE
```

### 4. Create Custom Actions
```gdscript
extends BehaviourTreeAction
class_name AttackPlayerAction

var attack_timer: float = 0.0
@export var attack_duration: float = 1.0

func tick(blackboard: BehaviourTreeBlackboard) -> int:
    var enemy = get_owner()
    
    if attack_timer <= 0:
        # Start attack
        enemy.start_attack_animation()
        attack_timer = attack_duration
        return BehaviourTreeResult.Status.RUNNING
    
    # Continue attack
    attack_timer -= get_process_delta_time()
    
    if attack_timer <= 0:
        # Attack finished
        enemy.finish_attack()
        return BehaviourTreeResult.Status.SUCCESS
    else:
        return BehaviourTreeResult.Status.RUNNING
```

## Architecture

### BehaviourTree (Root Manager)
The main coordinator that:
- Manages the blackboard (shared data)
- Executes the root node each frame
- Provides helper methods for blackboard access

### BehaviourTreeSelector (OR Logic)
Tries each child in priority order until one succeeds:
```
Selector
├── High Priority Branch → FAILURE (try next)
├── Medium Priority Branch → SUCCESS (stop here, return SUCCESS)
└── Low Priority Branch → (never reached)
```

### BehaviourTreeSequence (AND Logic)  
Executes children in order, all must succeed:
```
Sequence
├── Condition: "Can Attack?" → SUCCESS (continue)
├── Condition: "Not On Cooldown?" → SUCCESS (continue)
└── Action: "Attack" → SUCCESS (sequence succeeds)
```

### BehaviourTreeCondition (Leaf Node)
Override `tick()` to implement condition logic:
```gdscript
func tick(blackboard: BehaviourTreeBlackboard) -> int:
    # Check some game state
    if some_condition():
        return BehaviourTreeResult.Status.SUCCESS
    else:
        return BehaviourTreeResult.Status.FAILURE
```

### BehaviourTreeAction (Leaf Node)
Override `tick()` to implement action logic:
```gdscript
func tick(blackboard: BehaviourTreeBlackboard) -> int:
    # For instant actions:
    perform_action()
    return BehaviourTreeResult.Status.SUCCESS
    
    # For multi-frame actions:
    if not started:
        start_action()
        return BehaviourTreeResult.Status.RUNNING
    elif still_working():
        return BehaviourTreeResult.Status.RUNNING  
    else:
        finish_action()
        return BehaviourTreeResult.Status.SUCCESS
```

## Common Patterns

### Combat AI Pattern
```
Selector
├── Sequence (Flee - highest priority)
│   ├── Condition: "Health < 25%"
│   └── Action: "Flee from player"
├── Sequence (Attack - medium priority)
│   ├── Condition: "Player in attack range"
│   ├── Condition: "Not on cooldown"
│   └── Action: "Attack player"
├── Sequence (Chase - low priority)
│   ├── Condition: "Player detected"
│   └── Action: "Move toward player"
└── Action: "Patrol area" (fallback)
```

### Guard AI Pattern
```
Selector
├── Sequence (Investigate)
│   ├── Condition: "Heard suspicious noise"
│   └── Action: "Move to noise location"
├── Sequence (Chase)
│   ├── Condition: "Player spotted"  
│   └── Action: "Chase player"
└── Action: "Patrol waypoints"
```

## Testing

### Unit Tests
Test individual nodes in isolation:
```gdscript
func test_player_in_range_condition():
    var condition = CurrentTargetInRangeCondition.new()
    var blackboard = {
        "player_distance": 1.5,
        "attack_range": 2.0
    }
    
    var result = condition.tick(blackboard)
    assert_eq(result, BehaviourTreeResult.Status.SUCCESS)
```

### Integration Tests  
Test complete behavior trees:
```gdscript
func test_enemy_attacks_when_player_in_range():
    # Setup enemy with behavior tree
    var enemy = setup_enemy_with_bt()
    position_player_in_attack_range(enemy)
    
    # Tick the tree
    var result = enemy.behavior_tree.tick()
    
    # Verify attack behavior
    assert_eq(result, BehaviourTreeResult.Status.RUNNING)
    assert_true(enemy.is_attacking)
```

## Debugging Tips

### Visual Debugging
Add debug prints to see tree execution:
```gdscript
func tick(blackboard: BehaviourTreeBlackboard) -> int:
    var result = # ... your logic
    
    if debug_mode:
        print("%s: %s" % [get_class(), 
            "SUCCESS" if result == BehaviourTreeResult.Status.SUCCESS else
            "FAILURE" if result == BehaviourTreeResult.Status.FAILURE else "RUNNING"])
    
    return result
```

### Blackboard Inspection
Monitor blackboard contents:
```gdscript
func _process(_delta):
    if debug_mode:
        print("Blackboard: ", behavior_tree.blackboard)
```

### Common Issues
- **Tree always fails**: Check that at least one branch has a fallback action that always succeeds
- **Actions not executing**: Verify all conditions in the sequence are passing
- **Performance issues**: Avoid expensive calculations in conditions that run every frame

## Examples

See the test file `BehaviourTreeTest.gd` for comprehensive examples of tree construction and expected behavior.

## API Reference

### BehaviourTree Methods
- `tick() -> int`: Manually execute the tree once
- `set_blackboard_value(key: String, value: Variant)`: Store data
- `get_blackboard_value(key: String, default = null) -> Variant`: Retrieve data

### Node Base Classes
- `BehaviourTreeCondition`: Override `tick(blackboard)` for condition logic
- `BehaviourTreeAction`: Override `tick(blackboard)` for action logic
- `BehaviourTreeSelector`: Built-in OR logic composite
- `BehaviourTreeSequence`: Built-in AND logic composite

### Return Values
Always return one of:
- `BehaviourTreeResult.Status.SUCCESS`
- `BehaviourTreeResult.Status.FAILURE`  
- `BehaviourTreeResult.Status.RUNNING`