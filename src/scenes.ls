{ EntityManager, Player, Planet } = require \./entities.ls

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

    @add @player = new Player @

    for til 50
      @add new Planet @, (Math.random! - 0.5) * 100, (Math.random! - 0.5) * 100, if Math.random! > 0.66 then 2 else 4

  add: (entity) ->
    super ...
    if entity instanceof Planet then @planets.push entity

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

  render: (ctx) ->
    ctx.save!
    @camera.applyTransform ctx
    super ...
    ctx.restore!

module.exports = { Scene, Space }
