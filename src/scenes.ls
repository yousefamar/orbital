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
      @add new ORB.Planet @, (Math.random! - 0.5) * 100, (Math.random! - 0.5) * 200, if Math.random! > 0.66 then 2 else 4

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
    @camera.zoom = 1 + 9 * (1 - ((@player._radius-smooth - 0.798) / 24.73))

  render: (ctx) ->
    ctx.save!
    @camera.applyTransform ctx
    super ...
    ctx.restore!
