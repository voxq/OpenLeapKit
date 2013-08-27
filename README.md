OpenLeapKit
===============

A collaborative toolkit for the Leap Motion device.

Current Features:
- draws simple hands for 2D interaction (using various optional settings).
- detects whether a hand is right or left (simplistic technique of detecting shortest finger over a sampling period predominantly on right or left).
- translates vector information to a confined 2D (x,y) view using InteractionBox, with option to trim the InteractionBox.

Intended Features:
- stable hand/fingers such that they do not disappear simply because they vanished according to Leap's algorithms. Use last actions to estimate whether finger was closing, getting close to another finger, or... and then simulate the finger. When it comes back according to Leap, animate from simulated to real.
- draw 3D hand/fingers with option to confine to 2D surface (for screen interaction)
- Rig 3D mesh to hand/fingers
- advanced detection of right/left hands
- advanced detection of thumb
- diverse gestures and interactions
- ideas?
