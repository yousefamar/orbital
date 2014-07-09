{ Scene, Space } = require \./scenes.ls

options =
  debug: false
  tick-interval-ms: 1000ms/60

request-anim-frame = @request-animation-frame
    || @webkit-request-animation-frame
    || @moz-request-animation-frame
    || (callback) !->	@set-timeout callback, options.tick-interval-ms

window.main = do ->

  ctx = null

  gui =
    key-down: ->
    key-up: ->
    render: ->
  scene = null

  last-tick = Date.now!
  tick = !->
    # FIXME: Chrome throttles the interval down to 1s on inactive tabs.
    set-timeout tick, options.tick-interval-ms

    now = Date.now!
    scene.tick (now - last-tick)
    last-tick := now

  render = !->
    request-anim-frame render
    ctx.fill-style = \black
    ctx.fill-rect 0, 0, ctx.canvas.width, ctx.canvas.height

    scene.render ctx, options.debug
    gui.render ctx

  ->
    canvas = document.get-element-by-id \canvas
    ctx := canvas.get-context \2d
    ctx.font = '20pt Tahoma'

    scene := new Space!

    document.body.add-event-listener \keydown, !->
      (gui.key-down it.key-code) || (scene.key-down it.key-code)
    document.body.add-event-listener \keyup, ->
      (gui.key-up it.key-code) || (scene.key-up it.key-code)

    set-timeout tick, options.tick-interval-ms
    request-anim-frame render
