This game is a [space flight simulation game](https://en.m.wikipedia.org/wiki/Space_flight_simulation_game) with Newtonian flight mechanics at it's core. <br />
It aims at realistic hard Sci-Fi simulation of most aspects.

upcoming features

* command and fly space craft, from small drones to giant vehicles
* fight against enemy spacecraft

it features a Newtonian physics engine which also takes gravity into account.



# important about running / building the game with the Godot editor/engine

This is a Godot 4.1 project. Using a double build of the engine is * **highly RECOMMENDED** *.

To do that under Windows you have to build Godot with <br />
```scons platform=windows precision=double```

# about realism: (a love letter to realism)

Other space flight simulation games don't care about realism. This was very frustrating as a hard Sci-Fi fan. Physics of most space games looks like a cartoon of the physical real world.

Most of these soft Sci-Fi games which feature various unrelaistic "technologies" which will never be realized, because these are physically impossible, such as:

non-newtonian movement (dogfights, anti-gravity, lack of gravity forces) <br />
Shields / Force-Fields <br />
Warp / teleport / wormholes <br />
unrealistic damage model, with damage types such as "thermal", together with unrealistic scaling of the damage and forces. <br />
strange space anomalies <br />
dense asteroid fields <br />
smoke and clouds in space <br />
dense "nebulae" <br />

The question is then: why care about realism of these things if a computer can simulate anything which doesn't follow any physical laws. A few reasons:

immersion: it breaks immersion if a ship which weights 200 tons quickly stops as if it would be a sub-marine. <br />
plausibility: any knowledge gained by playing the game could be transfered to the physical real world and vice versa. This is NOT the case when the game features ANY physically impossible game mechanics. <br />
extensibility: some parts of the simulation could be used for simulating scientific experiments and vice versa. <br />

# extended features

These features may or may not be realized some day:

* realistic simulation of a economy
* atmospheric flight
