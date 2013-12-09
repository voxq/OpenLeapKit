OpenLeapKit
===========

"Open Source Leap Motion Device Toolkit"

![alt tag](https://raw.github.com/voxq/OpenLeapKit/2e63cc67b17bde820d68a61812cec57e215113c6/screenshots/single_hand-various_options.png)

![alt tag](https://raw.github.com/voxq/OpenLeapKit/master/screenshots/hand_3D-NUI_buttons.png)

![alt tag](https://raw.github.com/voxq/OpenLeapKit/master/screenshots/hand_to_screen_position_calibration.png)

Intended as a collaborative open source toolkit for the Leap Motion device. 

Initial focus is to provide a jumpstart for developers to move forward with ideas which utilize a 3D interaction device for their (novel) concept but are not attempting to break new ground towards a 3D interaction device specifically. Said another way, there are many things most developers are going to want to do with a Leap device, so why develop the same thing over and over. The case I would make, is that the community would be served well to have more idea expression, and less grappling with the technology.

Current Features:
- *New*: hand to screen position calibration
- *New*: Toggle and "Scratch" Buttons
- *New*: Circular menus.
- *New*: draws simple 3D hand/fingers confined to 2D surface (for screen interaction)
- draws simple hands for 2D interaction (using various optional settings).
- advanced detection of thumb (determine the finger with the greatest z value and above a threshold based on average of all fingers, relative to the palm, after transforming fingers to hand's reference space.)
- detects whether a hand is right or left (simplistic technique of detecting whether the shortest finger is predominantly on the right or left).
- translates vector information to a confined 2D (x,y) view using InteractionBox, with option to trim the InteractionBox.
- single hand postures with tolerance parameters: handUpright, handPalmDown
- two hand postures with tolerance parameters: handsMidPoint, handsFacing, handsFacingSame, handsPalmDown, handsUpright, handsBeside, handsNotFurtherThan, handArraySortedFromHands
- two hand complex postures with tolerance parameters: handsUprightAndFacing, handsClamped, handsClampedAndFacing, handsPalmDownAndBeside

Intended Features:
- extrapolated hand/fingers (ex. https://github.com/asetniop/Leap-Finger-Tracking) such that they do not disappear simply because they vanished according to Leap's algorithms. Use last actions to estimate whether finger was closing, getting close to another finger, or... and then simulate the finger. When it comes back according to Leap, animate from simulated to real.
- enable 3D movement in depth (z axis movement)
- Rig 3D mesh to hand/fingers
- advanced detection of right/left hands
- diverse gestures and interactions
- ideas?
