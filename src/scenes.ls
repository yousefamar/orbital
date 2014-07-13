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
      new Vector! # no gravity
      true        # objects may sleep
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
        console.log a, b

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
      @add new Planet @, (Math.random! - 0.5) * 100, (Math.random! - 0.5) * 100, if Math.random! > 0.66 then 2 else 4

  add: (entity) ->
    super ...
    if entity instanceof Planet then @planets.push entity
  remove: (entity) ->
    @entity-manager.remove entity
    if entity instanceof Planet
      @world.DestroyBody entity.body

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
        console.log it
        it.agent.mass *= 2
        @remove it.target
      ..length = 0 # empty it

    /*
    # TODO: Reduce complexity
    for i til @planets.length
      planet-a = @planets[i]
      for j from i+1 til @planets.length
        planet-b = @planets[j]
        #if planet-a is planet-b then continue
        dist-x = planet-b.x - planet-a.x
        dist-y = planet-b.y - planet-a.y
        dist-sq = (dist-x * dist-x + dist-y * dist-y)
        dist = Math.sqrt dist-sq
        unit-x = dist-x / dist
        unit-y = dist-y / dist
        mm = planet-a.mass * planet-b.mass
        force = if dist-x is 0 then 0 else 0.001 * mm / dist-sq
        planet-a.fx += force * unit-x
        planet-a.fy += force * unit-y
        planet-b.fx -= force * unit-x
        planet-b.fy -= force * unit-y

    for planet in @planets
      planet.prev-x = planet.x
      planet.prev-y = planet.y
      planet.vx += planet.fx
      planet.vy += planet.fy
      planet.x += planet.vx
      planet.y += planet.vy
      planet.fx = 0
      planet.fy = 0

    for i til @planets.length
      planet-a = @planets[i]
      for j from i+1 til @planets.length
        planet-b = @planets[j]
        if planet-a.collides-with planet-b
          if planet-a.mass == planet-b.mass
            absorber = planet-a
            absorbee = planet-b
            absorbee-id = j
            if absorbee is @player
              absorber = planet-b
              absorbee = planet-a
              absorbee-id = i
            absorbee.absorbed = true
            @planets.splice absorbee-id, 1
            # TODO: Don't hack LiveScript
            to$--
            to1$--
            absorber.mass *= 2
            for til 2
              @add new Planet @, @player.x + (Math.random! - 0.5) * 100, @player.y + (Math.random! - 0.5) * 100, if Math.random! > 0.66 then 2 else 4
          else
            inci-x = planet-a.x - planet-a.prev-x
            inci-y = planet-a.y - planet-a.prev-y
            dist-x = planet-b.x - planet-a.x
            dist-y = planet-b.y - planet-a.y
            dot = inci-x * dist-x + inci-y * dist-y
            dist-sq = dist-x * dist-x + dist-y * dist-y
            refl-x = inci-x - (2 * dot) * dist-x / dist-sq
            refl-y = inci-y - (2 * dot) * dist-y / dist-sq
            planet-a.vx += refl-x
            planet-a.vy += refl-y
            planet-b.vx -= refl-x
            planet-b.vy -= refl-y
    */

    @world
      ..Step delta / 100, 4 4
      ..ClearForces!

  render: (ctx) ->
    ctx.save!
    @camera.apply-transform ctx
    super ...
    ctx.restore!

module.exports = { Scene, Space }
