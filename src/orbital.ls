window.ORB =
  TICK_INTERVAL_MS: 1000ms/60

window.request-anim-frame = window.request-animation-frame
    || window.webkit-request-animation-frame
    || window.moz-request-animation-frame
    || (callback) !->	window.set-timeout callback, window.ORB.TICK_INTERVAL_MS

window.ORB.main = do

  ctx = null

  gui =
    key-down: ->
    key-up: ->
    render: ->
  scene =
    key-down: ->
    key-up: ->
    tick: ->
    render: ->

  last-tick = Date.now!
  tick = !->
    # FIXME: Chrome throttles the interval down to 1s on inactive tabs.
    setTimeout tick, ORB.TICK_INTERVAL_MS

    now = Date.now!
    scene.tick (now - last-tick)
    lastTick := now

  render = !->
    request-anim-frame render
    ctx.fill-style = \black
    ctx.fill-rect 0, 0, ctx.canvas.width, ctx.canvas.height

    scene.render ctx
    gui.render ctx

  ->
    canvas = document.get-element-by-id \canvas
    ctx := canvas.get-context \2d
    ctx.font = '20pt Tahoma'

    document.body.add-event-listener \keydown, !->
      (gui.key-down it.key-code) || (scene.key-down it.key-code)
    document.body.add-event-listener \keyup, ->
      (gui.key-up it.key-code) || (scene.key-up it.key-code)

    setTimeout tick, ORB.TICK_INTERVAL_MS
    request-anim-frame render
