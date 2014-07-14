# Destructure useful bits out of Box2dWeb into local scope
{
  Dynamics :
    b2BodyDef     : BodyDef
    b2FixtureDef  : FixtureDef
    b2Body        : Body
    b2World       : World
  Collision : Shapes : b2CircleShape : CircleShape
} = require "./Box2dWeb-2.1.a.3.js"

class EntityManager
  (@scene) ->
    @tick-queue   = []
    @render-queue = []

  add: (entity) ->
    if \tick   of entity then @tick-queue  .push entity
    if \render of entity then @render-queue.push entity

  remove: (entity) ->
    if \tick of entity then @tick-queue.splice do
      @tick-queue.index-of entity
      1
    if \render of entity then @render-queue.splice do
      @render-queue.index-of entity
      1

  tick: (delta) ->
    @tick-queue.for-each (.tick delta)

  render: (ctx, debug=false) ->
    @render-queue.for-each (.render ctx, debug)

class Entity
  (@scene, @x, @y) ->

class Planet extends Entity

  fix-def = new FixtureDef
    ..density = 10
    ..restitution = 1
  body-def = new BodyDef
    ..type = Body.b2_dynamic-body
    ..fixed-rotation = true

  @styles =
    2:
      pt: 9pt
      fg: \#776e65
      bg: \#eee4da
    4:
      pt: 13pt
      fg: \#776e65
      bg: \#ede0c8
    8:
      pt: 18pt
      fg: \#f9f6f2
      bg: \#f2b179
    16:
      pt: 24pt
      fg: \#f9f6f2
      bg: \#f59563
    32:
      pt: 32pt
      fg: \#f9f6f2
      bg: \#f67c5f
    64:
      pt: 50pt
      fg: \#f9f6f2
      bg: \#f65e3b
    128:
      pt: 50pt
      fg: \#f9f6f2
      bg: \#edcf72
    256:
      pt: 68pt
      fg: \#f9f6f2
      bg: \#edcc61
    512:
      pt: 90pt
      fg: \#f9f6f2
      bg: \#edc850
    1024:
      pt: 105pt
      fg: \#f9f6f2
      bg: \#edc53f
    2048:
      pt: 140pt
      fg: \#f9f6f2
      bg: \#edc22e

  (scene, x, y, mass) ->
    unless scene.world instanceof World
      return console.error "Planet constructor given scene without \
                            a physics world"
    super scene, x, y

    body-def
      ..position
        ..x = x
        ..y = y
      ..user-data = this
    @body = scene.world.CreateBody body-def
    @radius-smooth = 0
    @mass = mass # setter automatically creates fixture with correct radius


  #####################################################
  # Don't call property setters from Box2D callbacks! #
  #####################################################
  #
  # It leaves Box2D in an illegal state. Instead, buffer changes and execute
  # them once it's safe, such as just before calling `World.Step`.
  #

  position:~
    ->
      @body.GetPosition!
    (p) ->
      # *Ignored*: Box2D dynamic bodies respond to forces, not instant changes
      # in position.

  mass:~
    ->
      @_mass
    (mass) ->
      @_mass = mass

      # Box2D can't resize fixtures, so we replace it with one of right radius.
      # Area = 2 * PI * radius^2, so radius = sqrt ( Area / PI * 2 )
      @radius = Math.sqrt (mass / Math.PI)
      fix-def.shape = new CircleShape @radius
      @body.DestroyFixture @_circle-fixture if @_circle-fixture
      @_circle-fixture = @body.CreateFixture fix-def

      @_radius-changed = true
      @_style = @@styles[mass]

  tick: (delta) ->

  render: (ctx, debug=false) ->
    if @absorbed then return false
    if @_radius-changed
      @radius-smooth += 0.2 * (@radius - @radius-smooth)
      if Math.abs (@radius - @radius-smooth) < 0.01px
        @_radius-changed = false

    { x, y } = @position
    ctx.save!
    ctx.translate x, y
    ctx.begin-path!
    ctx.arc 0, 0, @radius-smooth, 0, 2 * Math.PI
    ctx.fill-style = @_style.bg
    ctx.fill!
    ctx.scale 0.1, 0.1
    ctx.font = "#{@_style.pt - 10 * (@radius - @radius-smooth)}pt Courier"
    ctx.text-align = \center
    ctx.text-baseline = \middle
    ctx.fill-style = @_style.fg
    ctx.fill-text "#{@mass}", 0, @radius-smooth
    ctx.restore!
    if debug
      ctx.save!
      ctx.font = '8px Arial'
      ctx.fill-style = \white
      ctx.fill-text "(#{x}, #{y})", x, y
      ctx.restore!


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

  tick: (delta) ->
    super ...
    # FIXME Use constant force, but just change its direction. (At the moment,
    # the total force applied is doubled if moving diagonally.)
    move-force = 0.001 * @mass
    x = y = 0
    @keys.w and y -= move-force
    @keys.s and y += move-force
    @keys.a and x -= move-force
    @keys.d and x += move-force
    @body.ApplyForce { x, y }, @position

class Star extends Entity
  ->
    super ...
    # Distance visualised as color rather than size to be less distracting
    rand = (Math.random! * 255).>>>.0
    @color = "rgb(#rand,#rand,#rand)"
    # Parallax distance
    @depth = (1 + Math.random! * 3).>>>.0

  render: (ctx, debug=false) ->
    cam = @scene.camera

    # Hacky viewport culling to prevent murdering FPS
    #   (Should really be done for all entities in a structured way)
    # NOTE: Hardcoded canvas dimensions here.
    if @x - cam.x/@depth < 0px or
       @x - cam.x/@depth > 800px or
       @y - cam.y/@depth < 0px or
       @y - cam.y/@depth > 450px
       return

    ctx.save!
    ctx.set-transform 1, 0, 0, 1, 0, 0
    ctx.translate -@scene.camera.x/@depth, -@scene.camera.y/@depth
    ctx.translate @x, @y
    ctx.begin-path!
    ctx.fill-style = @color
    ctx.rect 0, 0, 1, 1
    ctx.fill!
    if debug
      ctx.save!
      ctx.font = '8px Arial'
      ctx.fill-style = \white
      ctx.fill-text @color, 0, 0
      #ctx.fill-text "(#{@x - cam.x}, #{@y - cam.y})", 0, 0
      ctx.restore!
    ctx.restore!

module.exports = { Player, Planet, Star, EntityManager }
