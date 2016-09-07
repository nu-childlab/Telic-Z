# Telic Z

An experiment programmed in Matlab R2015a. This experiment also uses Psychtoolbox version 3.0.12. For more information, see [the github page](https://github.com/Psychtoolbox-3/Psychtoolbox-3).

This experiment contains 2 blocks of 20 trials, with two stimuli (images or animations) per trial. This results in a total of 40 trials.

##Experiment Design
This experiment followes the same 1-7 rating scale as Telic 1. It focuses on manipulating a continuous dimension (such as time for events and size for images).

For each trial, the first image/animation is shown with no extra modification; it is the stimuli set with a correlated time (see Wroclaw for time parameters) and the rotation and spatial separation from previous experiments. The second stimulus has additional time added if it is an animation, and additional size added if it is an image.

These differences are declared as a parameter towards the start of the script. Depending on the contrast between the number of loops in the trial, the additional change, hereafter referred to as zdiff, is larger or smaller. For example, an image trial with a declared spatial difference of 100px where one stimulus has 9 loops and the other has 4 would have a zdiff of 400px, and the second stimulus would have ellipses with areas that are 400px greater than the ellipses in the first stimulus. An animation trial with a declared temporal difference of .1 seconds (100ms) where one stimulus has 5 loops and the other has 8 would have a zdiff of .3s, and the second stimulus would take a total of .3s longer than the first stimulus (excluding break time).
