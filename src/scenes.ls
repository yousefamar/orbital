class ORB.Scene
  ->
    @entity-manager = new ORB.EntityManager @

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

class ORB.Space extends ORB.Scene
  ->
    super!

    @planets = []

    @camera =
      # NOTE: Hardcoded canvas dimensions here.
      zoom: 1
      x: -400px
      y: -225px
      moveTowards: (entity, speed) ->
        speed = speed || 0.1
        speed /= 1 + @zoom/10
        # NOTE: Hardcoded canvas dimensions here.
        @x += speed * (@zoom*entity.x- @x - 400px)
        @y += speed * (@zoom*entity.y- @y - 225px)
        #if @x < 0 then @x = 0
        #if @x > @limitX then @x = @limitX
        #if @y < 0 then @y = 0
        #if @y > @limitY then @y = @limitY
      applyTransform: (ctx) ->
        ctx.translate -@x, -@y
        ctx.scale @zoom, @zoom
        #ctx.translate -@x, -@y

    @add @player = new ORB.Player @

    for til 10
      @add new ORB.Planet @, (Math.random! - 0.5) * 10, (Math.random! - 0.5) * 200, if Math.random! > 0.66 then 2 else 4

  add: (entity) ->
    super ...
    if entity.mass > 0 then @planets.push entity

  key-down: (code) ->
    if code is 65 or code is 37
      @player.keys.a = true
    else if code is 68 or code is 39
      @player.keys.d = true
    else if code is 87 or code is 38
      @player.keys.w = true
    else if code is 83 or code is 40
      @player.keys.s = true

  key-up: (code) ->
    if code is 65 or code is 37
      @player.keys.a = false
    else if code is 68 or code is 39
      @player.keys.d = false
    else if code is 87 or code is 38
      @player.keys.w = false
    else if code is 83 or code is 40
      @player.keys.s = false

  tick: (delta) ->
    super ...
    @camera.moveTowards @player
    @camera.zoom = 1 + 9 * (1 - ((@player.radius-smooth - 0.798) / 24.73))

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
        force = if dist-x is 0 then 0 else mm / dist-sq
        planet-a.netfx += force * unit-x
        planet-a.netfy += force * unit-y
        planet-b.netfx -= force * unit-x
        planet-b.netfy -= force * unit-y

    for planet in @planets
      planet.x += planet.netfx
      planet.y += planet.netfy
      planet.netfx = 0
      planet.netfy = 0

  render: (ctx) ->
    ctx.save!
    @camera.applyTransform ctx
    super ...
    ctx.restore!
