class ORB.EntityManager
  (@scene) ->
    @tick-queue = new List!
    @render-queue = new List!
    @tangible-list = new List!

  add: (entity) ->
    if \tick of entity then @tick-queue.add entity
    if \render of entity then @render-queue.add entity
    if entity.mass > 0 then @tangible-list.add entity

  tick: (delta) ->
    for i from 0 til @tick-queue.size
      entity = @tick-queue.poll!
      (entity.tick delta) && @tick-queue.add entity

  render: (ctx) ->
    for i from 0 til @render-queue.size
      entity = @render-queue.poll!
      (entity.render ctx) && @render-queue.add entity

#  entityAt: (x, y) ->
#entityAtfor (var node = this.tangibleList.head; node; node = node.next) {
#next  //if node.e.contains(x, y);


class ORB.Entity
  (@scene, @x, @y) ->

#OOB.Entity.prototype.render = function(ctx) {
#	if (OOB.DEBUG && this.radius) {
#		ctx.save();
#		ctx.beginPath();
#		ctx.arc(this.x, this.y, this.radius, 0, 2 * Math.PI);
#		ctx.strokeStyle = 'red';
#		ctx.stroke();
#		ctx.restore();
#	}
#	if (this.sprite) {
#		ctx.drawImage(this.sprite.sheet, this.sprite.x, this.sprite.y, this.sprite.w, this.sprite.h, this.x-(this.w>>1), this.y-(this.h>>1), this.w, this.h);
#		return true;
#	}
#	return false;
#};
#
#OOB.Entity.prototype.collidesWith = function(x, y, r) {
#	if (!('radius' in this))
#		return false;
#
#	var xd = Math.abs(this.x - x);
#	var yd = Math.abs(this.y - y);
#	var rs = this.radius + r;
#	if (xd >= rs || yd >= rs)
#		return false;
#
#	return xd*xd + yd*yd < rs*rs;
#};
#

class ORB.Planet extends ORB.Entity
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
    @_radius-smooth = 0
    @_radius-changed = true
    @_style = @@styles[mass]

  mass:~
    -> @_mass
    (mass) ->
      @_mass = mass
      @radius = Math.sqrt mass/Math.PI
      @_radius-changed = true
      @_style = @@styles[mass]

  tick: (delta) ->

  render: (ctx) ->
    if @_radius-changed
      @_radius-smooth += 0.2 * (@_style.radius - @_radius-smooth)
      if Math.abs (@_style.radius - @_radius-smooth) < 0.01px then @_radius-changed = false
    ctx.save!
    ctx.translate @x, @y
    ctx.begin-path!
    ctx.arc 0, 0, @_radius-smooth, 0, 2 * Math.PI
    ctx.fill-style = @_style.bg
    ctx.fill!
    ctx.scale 0.1, 0.1
    ctx.font = "#{@_style.pt - 10 * (@_style.radius - @_radius-smooth)}pt Courier"
    ctx.text-align = \center
    ctx.text-baseline = \middle
    ctx.fill-style = @_style.fg
    ctx.fill-text "#{@mass}", 0, @_radius-smooth
    ctx.restore!
    if ORB.DEBUG
      ctx.save!
      ctx.font = '8px Arial'
      ctx.fill-style = \white
      ctx.fill-text "(#{@x}, #{@y})", @x, @y
      ctx.restore!
    true


class ORB.Player extends ORB.Planet
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
    move-speed = 0.5 + 0.005*@mass # pixels per tick
    if @keys.w then @y -= move-speed
    if @keys.a then @x -= move-speed
    if @keys.s then @y += move-speed
    if @keys.d then @x += move-speed
    true

#	var terrain = this.scene.terrain;
#	
#	while (terrain.tileAt(this.x, this.y) !== 2) {
#		this.y++;
#		if (terrain.tileAt(this.x, this.y + this.radius) === 1 || terrain.tileAt(this.x, this.y + this.radius) === undefined) {
#			// TODO: Respawn.
#			//console.log('Stranded!');
#			break;
#		}
#	}
#
#	// TODO: Tile types as constant variables.
#	while (terrain.tileAt(this.x + this.radius, this.y) === 1) this.x--;
#	while (terrain.tileAt(this.x - this.radius, this.y) === 1) this.x++;
#	while (terrain.tileAt(this.x, this.y + this.radius) === 1) this.y--;
#	while (terrain.tileAt(this.x, this.y - this.radius) === 1) this.y++;
#	// TODO: Scale to a spherical shape.
#	while (terrain.tileAt(this.x - this.radius, this.y - this.radius) === 1) {
#		this.x++;
#		this.y++;
#	}
#	while (terrain.tileAt(this.x + this.radius, this.y - this.radius) === 1) {
#		this.x--;
#		this.y++;
#	}
#	while (terrain.tileAt(this.x - this.radius, this.y + this.radius) === 1) {
#		this.x++;
#		this.y--;
#	}
#	while (terrain.tileAt(this.x + this.radius, this.y + this.radius) === 1) {
#		this.x--;
#		this.y--;
#	}
#
#	this.animTimer += delta * (dir!==4?8:1);
#	if (this.animTimer >= 1000) {
#		this.animFrame = ((this.animFrame+1)%3)>>0;
#		this.animTimer = this.animTimer%1000;
#	}
#
#	if (terrain.tileAt(this.x, this.y - this.radius) === 0) {
#		this.breath = 10;
#		this.breathTimer = 0;
#	} else {
#		this.breathTimer += delta;
#		if (this.breathTimer >= 1000) {
#			if(--this.breath <= 0)
#				this.respawn();
#			this.breathTimer = this.breathTimer%1000;
#		}
#	}
#
#	this.sprite = OOB.Player.prototype.sprites[dir][this.animFrame];
#
#	return true;
#};








#
#OOB.Terrain = function (scene, map) {
#	OOB.Entity.call(this, scene);
#
#	this.map = map;
#	this.tiles = [];
#	for (var x = 0, cols = map.width; x < cols; x++) {
#		this.tiles[x] = [];
#		for (var y = 0, rows = map.height; y < rows; y++) {
#			var pixel = map.getPixel(x, y);
#
#			if ((pixel[0] === 255 && pixel[1] === 255 && pixel[2] === 0)) {
#				this.tiles[x][y] = 1;
#				this.chestCoords = { x: x*this.tileSize, y: y*this.tileSize };
#			} else {
#				/*
#				 * Tile IDs:
#				 * 0: Air
#				 * 1: Earth
#				 * 2: Water
#				 *
#				 */
#				this.tiles[x][y] = (pixel[3] === 0)?0:
#						(pixel[0] === 0 && pixel[1] === 0 && pixel[2] === 0)?1:
#						(pixel[0] === 0 && pixel[1] === 0 && pixel[2] === 255)?2:
#						0;
#			}
#		}
#	}
#
#	this.seaLevel = map.height;
#	seaLevelSearch:
#	for (var y = 0, rows = map.height; y < rows; y++) {
#		for (var x = 0, cols = map.width; x < cols; x++) {
#			if (this.tiles[x][y] === 2) {
#				this.seaLevel = y;
#				break seaLevelSearch;
#			}
#		}
#	}
#
#	/*
#	for (var x = 0, cols = map.width; x < cols; x++) {
#		this.tiles[x] = [];
#		for (var y = 0, rows = map.height; y < rows; y++) {
#			var pixel = map.getPixel(x, y);
#			this.tiles = (pixel[0] === 255 && pixel[1] === 255 && pixel[2] === 255 && pixel[3] === 255);
#		}
#	}
#	*/
#};
#
#OOB.Terrain.prototype = Object.create(OOB.Entity.prototype);
#
#OOB.Terrain.prototype.tileSize = 8;
#
#OOB.Terrain.prototype.tileAt = function (x, y) {
#	x = (x/this.tileSize)>>0;
#	y = (y/this.tileSize)>>0;
#	return this.tiles[x][y];
#};
#
#OOB.Terrain.prototype.colAt = function (x, y) {
#	x = (x/this.tileSize)>>0;
#	y = (y/this.tileSize)>>0;
#	return this.colMap[x][y];
#};
#
#/*
#OOB.Terrain.prototype.tick = function (delta) {
#
#};
#*/
#
#OOB.Terrain.prototype.render = function (ctx) {
#	ctx.save();
#	// NOTE: Canvas dimensions hardcoded here.
#	var viewportLeft = (this.scene.camera.x/this.tileSize)>>0;
#	var viewportRight = ((this.scene.camera.x+800+this.tileSize)/this.tileSize)>>0;
#	var viewportTop = (this.scene.camera.y/this.tileSize)>>0;
#	var viewportBottom = ((this.scene.camera.y+450+this.tileSize)/this.tileSize)>>0;
#	for (var x = Math.max(viewportLeft, 0), cols = Math.min(viewportRight, this.tiles.length); x < cols; x++) {
#		for (var y = Math.max(viewportTop, 0), rows = Math.min(viewportBottom, this.tiles[x].length); y < rows; y++) {			
#			switch (this.tiles[x][y]) {
#			/* Earth */
#			case 1:
#				ctx.fillStyle = '#3E2A08';
#				break;
#			/* Water */
#			case 2:
#				ctx.fillStyle = '#140080';
#				break;
#			/* Air */
#			default:
#				ctx.fillStyle = y<this.seaLevel?'#CBE9FF':'#553500';
#				break;
#			}
#			ctx.fillRect(x*this.tileSize, y*this.tileSize, this.tileSize+1, this.tileSize+1);
#		}
#	}
#	ctx.restore();
#	return true;
#};
#
#
#OOB.Player = function (scene, x, y) {
#	OOB.Entity.call(this, scene, x, y);
#
#	this.spawnPosX = x;
#	this.spawnPosY = y;
#
#	this.radius = 16;
#
#	this.keys = {
#		w: false,
#		a: false,
#		s: false,
#		d: false
#	};
#
#	this.animFrame = 1;
#	this.animTimer = 0;
#
#	this.breath = 10;
#	this.breathTimer = 0;
#};
#
#
#
#OOB.SeaWeed = function (scene, x, y) {
#	OOB.Entity.call(this, scene, x, y, 64, 64);
#
#	this.animFrame = ((Math.random()*4)>>0)%4;
#	this.animTimer = 0;
#
#	this.bubbleTimer = ((Math.random()*10000)>>0)%10000;
#};
#
#OOB.SeaWeed.prototype = Object.create(OOB.Entity.prototype);
#
#OOB.SeaWeed.prototype.tick = function(delta) {
#	this.animTimer += delta;
#	if (this.animTimer >= 1000) {
#		this.animFrame = ((this.animFrame+1)%4)>>0;
#		this.animTimer = this.animTimer%1000;
#	}
#
#	this.bubbleTimer += delta;
#	if (this.bubbleTimer >= 10000) {
#		this.scene.add(new OOB.Bubble(this.scene, this.x, this.y));
#		this.bubbleTimer = this.bubbleTimer%10000;
#	}
#
#	this.sprite = OOB.SeaWeed.prototype.sprites[this.animFrame];
#
#	return true;
#};
#
#OOB.Bubble = function (scene, x, y) {
#	OOB.Entity.call(this, scene, x, y, 32, 32);
#
#	this.radius = 16;
#
#	this.animFrame = ((Math.random()*4)>>0)%4;
#	this.animTimer = 0;
#};
#
#OOB.Bubble.prototype = Object.create(OOB.Entity.prototype);
#
#OOB.Bubble.prototype.tick = function(delta) {
#	this.y--;
#
#	var player = this.scene.player;
#	if (this.collidesWith(player.x, player.y, player.radius)) {
#		player.breath = 10;
#		player.breathTimer = 0;
#		this.sprite = null;
#		return false;
#	}
#
#	if (this.scene.terrain.tileAt(this.x, this.y - this.radius) !== 2) {
#		this.sprite = null;
#		return false;
#	}
#
#	this.animTimer += delta;
#	if (this.animTimer >= 200) {
#		this.animFrame = ((this.animFrame+1)%4)>>0;
#		this.animTimer = this.animTimer%200;
#	}
#
#	this.sprite = OOB.Bubble.prototype.sprites[this.animFrame];
#
#	return true;
#};
#
#OOB.Chest = function (scene, x, y) {
#	OOB.Entity.call(this, scene, x, y, 64, 64);
#
#	this.radius = 32;
#};
#
#OOB.Chest.prototype = Object.create(OOB.Entity.prototype);
#
#OOB.Chest.prototype.tick = function(delta) {
#	var player = this.scene.player;
#	if (this.collidesWith(player.x, player.y, player.radius)) {
#		this.scene.winFunc();
#		return false;
#	}
#	return true;
#};
