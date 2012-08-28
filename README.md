GameAssetOrganizer, a way to organize game assets into LevelPack / Level Spritesheets
================================

This is a simple Mac tool that allows to define a Levelpack / Level Structure and assign images from a pre-defined folder hierachy into these folders. 
This setup can then be exported as a json configuration file, so that commandline scripts in your pipeline can read it and create sprite sheets out of these configurations.

Simple example:
--------------
Say you have a nice image of a tree that you want to use in almost all your levelpacks. You also have a special image of a trailer that should only be used in the second level pack

With this tool, you can define two different sprite sheets, one for level pack 1, one for level pack 2, both having the tree image, while only the second one gets the trailer.

The main use case of this tool is to have a visual indication of which items go into which level pack. This makes it a lot easier to plan complex setups with several spritessehts.

The tool looks like this:

![Screenshot of GameAssetOrganizer](https://raw.github.com/terhechte/GameAssetOrganizer/master/screenshot.jpg)

About
--------------
We're using this tool in our upcoming game [Flick a Fruit](http://mjamstudios.com/flickafruit.html). The game is still in development, we're planning to release more tools along the way.
