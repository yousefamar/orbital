{ Scene, Space } = require \./scenes.ls

options =
  debug: false
  tick-interval-ms: 1000ms/60

request-anim-frame = @request-animation-frame
    || @webkit-request-animation-frame
    || @moz-request-animation-frame
    || (callback) !->	@set-timeout callback, options.tick-interval-ms

tick = do
  previous = Date.now!
  (tickables) !->
    now = Date.now!
    dt = (now - previous)
    tickables.for-each -> it.tick dt
    previous := now

render = (ctx, renderables, debug=false) !->
  ctx
    ..fill-style = \black
    ..fill-rect 0, 0, ctx.canvas.width, ctx.canvas.height

  renderables.for-each -> it.render ctx, debug

window.main = ->
  ctx = document.get-element-by-id \canvas .get-context \2d
    ..font = '20pt Tahoma'

  scene = new Space!
  gui =
    key-down: ->
    key-up: ->
    render: ->

  document.body.add-event-listener \keydown, !->
    (gui.key-down it.key-code) || (scene.key-down it.key-code)
  document.body.add-event-listener \keyup, !->
    (gui.key-up it.key-code) || (scene.key-up it.key-code)

  # FIXME: Chrome throttles the interval down to 1s on inactive tabs.
  set-interval do
    -> tick [ scene ]
    options.tick-interval-ms

  render-loop = ->
    request-anim-frame render-loop
    render ctx, [ scene, gui ], options.debug
  render-loop!
