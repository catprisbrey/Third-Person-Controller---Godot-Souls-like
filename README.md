# Third Person Controller Template - Godot Souls-Like
Version 1.0.3

![Controller Screenshot](https://github.com/pemguin005/Third-Person-Controller---Godot-Souls-like/blob/main/screenshots/HunterGodotDemo.GIF)

## Features

A template and demo character for a souls-like, melee focused 3rd person controller and camera. Follow the youtube video to see how to drop in your own characters. Features pre-mapped animations tree nodes, state based conditions, 360 camera, strafe, combo melee attacks, special attacks, keyboard, mouse and and game-pad support.
Quick applying template only requires: 

-Key inputs be mapped

-A GLTF 3D model with animations too drop into the template (Idle, walk, run, jump, roll, attacks) 

-These three files: PlayerTemplate.tscn, PlayerTemplate.gb, and CameraTemplate.gb).

This is a souls-like controller aimed at setting up character models with souls-like controller mechanics very quickly. 

## Installation of the entire Demo

Download the Template files, and open Godot.
Select "Import" and import the project. 

## Installation of just the controller template.

You only need the following files:

- PlayerTemplate.tscn

- PlayerTemplate.gd

- CameraTemplate.gd

Add those to your project and you'll be able to drop in the PlayerTemplate scene and add your character.
The code expects certain keymaps to be present:

"sprint, aim, jump, roll, attack, forward, backward, left, right"
and for gamepad support:
"lookup, lookdown, lookleft, lookright"

If you have those mapped, and the files present, the controller should work.

## Usage
Watch this video or follow the steps below:

https://youtu.be/GQ96m3ZBLY0

In the Scene menu, delete the "GodotSouls" KinematicBody and children.

Drag the "player\PlayerTemplate.tscn" file into the world scene. 
Open your own character, and copy/paste your Mesh and AnimationPlayer containing your character's animatinos. This template expects to see an Idle, Walk, Run, Roll, Jump, Attack1, Attack2, and Big Attack, although all these aren't necessary, jump and roll could be the same really, or each attack could be the same animation. 

Copy and paste into your Mesh and AnimationPlayer into the PlayerTemplate scene.

In the Scene menu, click on the KinematicBody node, and in the inspector click the "Player Animation Tree" button, and select the AnimationTree. 

Click the "Player Character Mesh" button and select any parent node of your 3D character mesh. Additional physics options are below if you want to speed up or slow down your character's actions.

In the Scene menu, select the Camroot spatial node. In the inspector click the "Player Character Mesh" button and select any parent node of your 3d Character mesh. 

In the Scene menu, select AnimationTree and click the "Anim Player" button and select your 3D meshes AnimationPlayer.

Inside the AnimationTree state machine node window, click on each action node.
For Idle, in the inspector click the dropdown and select your Idle-loop animatino
For Walk, Run, Etc, do the same, matching your animations with the actions of each node.

Save and run the game, all animations and controls should work.

License
[MIT](https://choosealicense.com/licenses/mit/)
