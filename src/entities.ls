{ List } = require \./utils.ls

class EntityManager
  (@scene) ->
    @tick-queue = new List!
    @render-queue = new List!

  add: (entity) ->
    if \tick of entity then @tick-queue.add entity
    if \render of entity then @render-queue.add entity

  tick: (delta) ->
    for til @tick-queue.size
      entity = @tick-queue.poll!
      (entity.tick delta) && @tick-queue.add entity

  render: (ctx, debug=false) ->
    for til @render-queue.size
      entity = @render-queue.poll!
      (entity.render ctx, debug) && @render-queue.add entity

class Entity
  (@scene, @x, @y) ->


class Planet extends Entity
  @styles =
    2:
      pt: 9pt
      fg: \#776e65
      bg: \#eee4da
      radius: Math.sqrt 2/Math.PI
    4:
      pt: 13pt
      fg: \#776e65
      bg: \#ede0c8
      radius: Math.sqrt 4/Math.PI
    8:
      pt: 18pt
      fg: \#f9f6f2
      bg: \#f2b179
      radius: Math.sqrt 8/Math.PI
    16:
      pt: 24pt
      fg: \#f9f6f2
      bg: \#f59563
      radius: Math.sqrt 16/Math.PI
    32:
      pt: 32pt
      fg: \#f9f6f2
      bg: \#f67c5f
      radius: Math.sqrt 32/Math.PI
    64:
      pt: 50pt
      fg: \#f9f6f2
      bg: \#f65e3b
      radius: Math.sqrt 64/Math.PI
    128:
      pt: 50pt
      fg: \#f9f6f2
      bg: \#edcf72
      radius: Math.sqrt 128/Math.PI
    256:
      pt: 68pt
      fg: \#f9f6f2
      bg: \#edcc61
      radius: Math.sqrt 256/Math.PI
    512:
      pt: 90pt
      fg: \#f9f6f2
      bg: \#edc850
      radius: Math.sqrt 512/Math.PI
    1024:
      pt: 105pt
      fg: \#f9f6f2
      bg: \#edc53f
      radius: Math.sqrt 1024/Math.PI
    2048:
      pt: 140pt
      fg: \#f9f6f2
      bg: \#edc22e
      radius: Math.sqrt 2048/Math.PI

  (scene, x, y, @mass) ->
    super scene, x, y
    @radius = Math.sqrt mass/Math.PI
    @radius-smooth = 0
    @vx = 0
    @vy = 0
    @fx = 0
    @fy = 0
    @_radius-changed = true
    @_style = @@styles[mass]

  mass:~
    -> @_mass
    (mass) ->
      @_mass = mass
      @radius = Math.sqrt mass/Math.PI
      @_radius-changed = true
      @_style = @@styles[mass]

  collides-with: (planet) ->
    dist-x = Math.abs @x - planet.x
    dist-y = Math.abs @y - planet.y
    radii = @radius-smooth + planet.radius-smooth
    if dist-x >= radii or dist-y >= radii then return false
    dist-x * dist-x + dist-y * dist-y < radii * radii

  tick: (delta) ->

  render: (ctx, debug=false) ->
    if @absorbed then return false
    if @_radius-changed
      @radius-smooth += 0.2 * (@_style.radius - @radius-smooth)
      if Math.abs (@_style.radius - @radius-smooth) < 0.01px then @_radius-changed = false
    ctx.save!
    ctx.translate @x, @y
    ctx.begin-path!
    ctx.arc 0, 0, @radius-smooth, 0, 2 * Math.PI
    ctx.fill-style = @_style.bg
    ctx.fill!
    ctx.scale 0.1, 0.1
    ctx.font = "#{@_style.pt - 10 * (@_style.radius - @radius-smooth)}pt Courier"
    ctx.text-align = \center
    ctx.text-baseline = \middle
    ctx.fill-style = @_style.fg
    ctx.fill-text "#{@mass}", 0, @radius-smooth
    ctx.restore!
    if debug
      ctx.save!
      ctx.font = '8px Arial'
      ctx.fill-style = \white
      ctx.fill-text "(#{@x}, #{@y})", @x, @y
      ctx.restore!
    true


class Player extends Planet
  (scene) ->
    super scene, 0px, 0px, 2N
    #self = @
    #set-interval (-> if self.mass < 2048 then self.mass *= 2), 1000

    @keys =
      w: false
      a: false
      s: false
      d: false

  respawn: !->
    @keys.w = false
    @keys.a = false
    @keys.s = false
    @keys.d = false

    @x = 0
    @y = 0

  tick: (delta) ->
    super ...
    move-speed = 0.02 * (0.5 + 0.005*@mass) # pixels per tick
    if @keys.w then @vy -= move-speed
    if @keys.a then @vx -= move-speed
    if @keys.s then @vy += move-speed
    if @keys.d then @vx += move-speed
    true

module.exports = { Player, Planet, EntityManager }
