# Coastal-Contention-V2

This is a game I'm building with Godot that is a reboot of my scrapped project Coastal Contention from scratch. The only assets I'm keeping are the sprites.

## How to Play

To play, go to <https://cattacocattaco.github.io/Coastal-Contention-V2/v0_2_1>. (patched version of v0.2.0)

### Controls:

#### Setup:

* Select the options you want
  * Map sizing: Grow to cover will make the map expand to the next scale above your screen size (only integer scale factors are used), while shrink to fit will make the map shrink to the scale below your screen size. The option does nothing if your screen size is less than or equal to the map size.
* Press start
* For each player that isn't the Mycolings, choose the territories to recruit to
  * Pirates get 4 troops in each of 3 red territories
  * Clerics get 2 troops in gold territories of each of the 4 biomes
    * Either one troop in each of the two territories or two troops in one of the two territories
  * Mycolings get 1 troop in each territory that borders at least one magenta territory (including magenta territories)

#### Post-Setup:
* Press one of the three action buttons on the side to move, attack, or pass the turn to the next player
* Moving:
  * Once you press the move button, press the territory you want to move troops from
  * Then, press the neighboring territory you want to move them to
  * Finally, enter the number of troops you want to move
* Attacking:
  * Once you press the move button, press the territory you want to attack in
  * Then, press the player in the turn order bar that you want to attack
  * Afterwards, you will roll a number of dice based on your troop count and the defender will roll dice based on their troop count, and each player scores a number of hits (troops removed from the other side) equal to number of dice that reach a threshold
    * Attacker: Max 4 dice, rolls >= 3 are hits
    * Defender: Max 6 dice, rolls >= 4 are hits
* Recruiting
  * Once you press the recruit button, press the territory you want to recruit in
  * Then, you will get one troop in that territory
* Canceling an action:
  * At any point, if you want to cancel the action you are midway through, you can select a different action or press the cancel button

### Objective

The goal is to be the last one standing.

## Screenshots

![Attacking](/screenshots/attacking.png)
![Last Action](/screenshots/last_action.png)
![Cleric Turn](/screenshots/cleric_turn.png)
