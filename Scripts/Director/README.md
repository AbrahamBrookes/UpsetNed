# res://Scripts/Director

The Director coordinates EnemyCharacters. This is a script that basically tracks all EnemyCharacters in the scene and gives them combat roles. The EnemyCharacters will decide how to act based on the role assigned to them by the Director and their own behaviour tree.

Enemies get given a role by the Director and their behaviour tree executes a branch depending on the role.

## Roles

 - **Strafer**: This enemy will try to circle strafe around the player while shooting at them. The idea is to give the player something to shoot at. They won't dive, slide or jump, just strafe and shoot.
 - **Passer**: This enemy will dive or slide past the player while shooting at them. The idea is to give the player a moving target that is harder to hit and increase the franticness of combat.
 - **Disengager**: This enemy will attempt to find cover and shoot from a distance. The idea is to give the player something to seek out and force them to move around the environment. Most aggressive roles will switch to disengager before re-engaging to give the player a breather.
 - **Rusher**: This enemy will rush directly at the player, using jumps, dives and slides to get in close. The idea is to pressure the player and force them to react quickly.
 - **Alarmer**: This enemy will try to reach an alarm point to call for reinforcements. The idea is to add an objective for the player to stop, adding variety to combat encounters. This behaviour needs to be highly readable to give the player a chance to stop it.

## Pressure
Depending on how much pressure we want to put on the player we can adjust the number of enemies in each role. For example, if we want to increase pressure we can add more Rushers and Passers. If we want to decrease pressure we can add more Disengagers. This should allow us to give the player peaks and troughs in combat intensity and react to their performance.