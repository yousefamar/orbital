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
      x: -400px
      y: -225px
      moveTowards: (entity, speed) ->
        speed = speed || 0.05
        # NOTE: Hardcoded canvas dimensions here.
        @x += speed * (entity.x-400-@x)
        @y += speed * (entity.y-225-@y)
        #if @x < 0 then @x = 0
        #if @x > @limitX then @x = @limitX
        #if @y < 0 then @y = 0
        #if @y > @limitY then @y = @limitY
      applyTransform: (ctx) ->
        ctx.translate -@x, -@y

    # TODO: Spawn scene entities here
    #@add(@terrain = new ORB.Terrain(@ map))
    @add @player = new ORB.Player @

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

  render: (ctx) ->
    ctx.save!
    @camera.applyTransform ctx
    super ...
    ctx.restore!
