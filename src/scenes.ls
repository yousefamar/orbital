{ EntityManager, Player, Planet } = require \./entities.ls
{
  Common : Math : b2Vec2 : Vector
  Dynamics :
    b2World : World
    b2ContactListener : ContactListener
} = require "./Box2dWeb-2.1.a.3.js"

class Scene
  ->
    @entity-manager = new EntityManager @

  add: (entity) -> @entity-manager.add entity

  mouse-down: (x, y, event) ->
  mouse-move: (x, y) ->
  mouse-up: (x, y, event) ->
  key-down: (code) ->
  key-up: (code) ->
  tick: (delta) ->
    @entity-manager.tick delta
  render: (ctx) ->
    @entity-manager.render ctx

class Space extends Scene
  ->
    super!

    @world = new World do
      new Vector! # No global gravity.
      no          # Objects may not sleep: Sleep easily triggers
                    # and causes unpredictable behaviour when gravitational
                    # force on a planet is small but still significant.
    @planets = []
    @absorptions = []

    @camera =
      # NOTE: Hardcoded canvas dimensions here.
      zoom: 1
      x: -400px
      y: -225px
      move-towards: (entity, speed=0.1) ->
        speed /= 1 + @zoom/10
        # NOTE: Hardcoded canvas dimensions here.
        { x : entity-x, y : entity-y } = entity.position
        @x += speed * (@zoom*entity-x - @x - 400px)
        @y += speed * (@zoom*entity-y - @y - 225px)
        #if @x < 0 then @x = 0
        #if @x > @limitX then @x = @limitX
        #if @y < 0 then @y = 0
        #if @y > @limitY then @y = @limitY
      apply-transform: (ctx) ->
        ctx.translate -@x, -@y
        ctx.scale @zoom, @zoom
        #ctx.translate -@x, -@y

    contact-listener = new ContactListener
      ..BeginContact = ~>
        a = it.Get-fixture-a!Get-body!Get-user-data!
        b = it.Get-fixture-b!Get-body!Get-user-data!

        # Assuming both are Planets

        if a.mass is b.mass
          @absorptions.push switch
            case a instanceof Player =>
              agent : a, target : b
            case b instanceof Player =>
              agent : b, target : a
            case otherwise =>
              if Math.random! < 0.5 # Coin toss
              then agent : a, target : b
              else agent : b, target : a
    @world.SetContactListener contact-listener

    @add @player = new Player @

    for til 50

      # Place a new planet somewhere within a circle
      radius = 50 * Math.random!
      angle  = Math.random! * Math.PI * 2

      p = new Planet do
        @
        radius * Math.cos angle
        radius * Math.sin angle
        if Math.random! > 0.66 then 2 else 4

      # Apply an initial force to get some orbits going
      magnitude = 0.006 # TODO Actually calculate what you need for an orbit?
      direction = angle + Math.PI / 2 # tangent to centre of "solar system"
      p.body.ApplyForce do
        * x : magnitude * Math.cos direction
          y : magnitude * Math.sin direction
        * p.body.Get-position!
      @add p

  add: (entity) ->
    super ...
    if entity instanceof Planet then @planets.push entity
  remove: (entity) ->
    @entity-manager.remove entity
    if entity instanceof Planet
      @world.DestroyBody entity.body
      @planets.splice do
        @planets.index-of entity
        1

  key-down: (code) ->
    @player.keys
      ..a = true if code in [ 65 37 ]
      ..d = true if code in [ 68 39 ]
      ..w = true if code in [ 87 38 ]
      ..s = true if code in [ 83 40 ]

  key-up: (code) ->
    @player.keys
      ..a = false if code in [ 65 37 ]
      ..d = false if code in [ 68 39 ]
      ..w = false if code in [ 87 38 ]
      ..s = false if code in [ 83 40 ]

  tick: (delta) ->
    super ...
    @camera.move-towards @player
    @camera.zoom = 1 + 9 * (1 - ((@player.radius-smooth - 0.798) / 24.73))

    @absorptions
      ..for-each ~>
        it.agent.mass *= 2
        @remove it.target
      ..length = 0 # empty it

    # Apply Newton's general gravitation between each pair of planets.
    #
    # This is a naive `O(n^2)` n-body simulation.
    # TODO Use the Barnes-Hut method (point quadtree) for `O(n log n)` .
    @planets.for-each (a) ~>
      @planets.for-each (b) ~>
        return if a is b

        # Beef up force of gravity so it has a noticeable effect on bodies the
        # mass of which Box2D can comprehend.

        G = 6.67e-11
        artistic-license = 10_000_000Shakespeares
        dx = a.position.x - b.position.x
        dy = a.position.y - b.position.y
        r-squared = dx^2 + dy^2
        magnitude = -G * a.mass * b.mass / r-squared * artistic-license
        angle = Math.atan2 dy, dx
        a.body.Apply-force do
          * x : magnitude * Math.cos angle
            y : magnitude * Math.sin angle
          * a.body.Get-position!

    @world
      ..Step delta, 10 10
      ..ClearForces!

  render: (ctx) ->
    ctx.save!
    @camera.apply-transform ctx
    super ...
    ctx.restore!

module.exports = { Scene, Space }
