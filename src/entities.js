// Generated by LiveScript 1.2.0
var EntityManager, Entity, Planet, Player;
ORB.EntityManager = EntityManager = (function(){
  EntityManager.displayName = 'EntityManager';
  var prototype = EntityManager.prototype, constructor = EntityManager;
  function EntityManager(scene){
    this.scene = scene;
    this.tickQueue = new List();
    this.renderQueue = new List();
  }
  prototype.add = function(entity){
    if ('tick' in entity) {
      this.tickQueue.add(entity);
    }
    if ('render' in entity) {
      return this.renderQueue.add(entity);
    }
  };
  prototype.tick = function(delta){
    var i$, to$, entity, results$ = [];
    for (i$ = 0, to$ = this.tickQueue.size; i$ < to$; ++i$) {
      entity = this.tickQueue.poll();
      results$.push(entity.tick(delta) && this.tickQueue.add(entity));
    }
    return results$;
  };
  prototype.render = function(ctx){
    var i$, to$, entity, results$ = [];
    for (i$ = 0, to$ = this.renderQueue.size; i$ < to$; ++i$) {
      entity = this.renderQueue.poll();
      results$.push(entity.render(ctx) && this.renderQueue.add(entity));
    }
    return results$;
  };
  return EntityManager;
}());
ORB.Entity = Entity = (function(){
  Entity.displayName = 'Entity';
  var prototype = Entity.prototype, constructor = Entity;
  function Entity(scene, x, y){
    this.scene = scene;
    this.x = x;
    this.y = y;
  }
  return Entity;
}());
ORB.Planet = Planet = (function(superclass){
  var prototype = extend$((import$(Planet, superclass).displayName = 'Planet', Planet), superclass).prototype, constructor = Planet;
  Planet.styles = {
    2: {
      pt: 9,
      fg: '#776e65',
      bg: '#eee4da',
      radius: Math.sqrt(2 / Math.PI)
    },
    4: {
      pt: 13,
      fg: '#776e65',
      bg: '#ede0c8',
      radius: Math.sqrt(4 / Math.PI)
    },
    8: {
      pt: 18,
      fg: '#f9f6f2',
      bg: '#f2b179',
      radius: Math.sqrt(8 / Math.PI)
    },
    16: {
      pt: 24,
      fg: '#f9f6f2',
      bg: '#f59563',
      radius: Math.sqrt(16 / Math.PI)
    },
    32: {
      pt: 32,
      fg: '#f9f6f2',
      bg: '#f67c5f',
      radius: Math.sqrt(32 / Math.PI)
    },
    64: {
      pt: 50,
      fg: '#f9f6f2',
      bg: '#f65e3b',
      radius: Math.sqrt(64 / Math.PI)
    },
    128: {
      pt: 50,
      fg: '#f9f6f2',
      bg: '#edcf72',
      radius: Math.sqrt(128 / Math.PI)
    },
    256: {
      pt: 68,
      fg: '#f9f6f2',
      bg: '#edcc61',
      radius: Math.sqrt(256 / Math.PI)
    },
    512: {
      pt: 90,
      fg: '#f9f6f2',
      bg: '#edc850',
      radius: Math.sqrt(512 / Math.PI)
    },
    1024: {
      pt: 105,
      fg: '#f9f6f2',
      bg: '#edc53f',
      radius: Math.sqrt(1024 / Math.PI)
    },
    2048: {
      pt: 140,
      fg: '#f9f6f2',
      bg: '#edc22e',
      radius: Math.sqrt(2048 / Math.PI)
    }
  };
  function Planet(scene, x, y, mass){
    this.mass = mass;
    Planet.superclass.call(this, scene, x, y);
    this.radius = Math.sqrt(mass / Math.PI);
    this.radiusSmooth = 0;
    this.vx = 0;
    this.vy = 0;
    this.fx = 0;
    this.fy = 0;
    this._radiusChanged = true;
    this._style = constructor.styles[mass];
  }
  Object.defineProperty(prototype, 'mass', {
    get: function(){
      return this._mass;
    },
    set: function(mass){
      this._mass = mass;
      this.radius = Math.sqrt(mass / Math.PI);
      this._radiusChanged = true;
      this._style = constructor.styles[mass];
    },
    configurable: true,
    enumerable: true
  });
  prototype.collidesWith = function(planet){
    var distX, distY, radii;
    distX = Math.abs(this.x - planet.x);
    distY = Math.abs(this.y - planet.y);
    radii = this.radiusSmooth + planet.radiusSmooth;
    if (distX >= radii || distY >= radii) {
      return false;
    }
    return distX * distX + distY * distY < radii * radii;
  };
  prototype.tick = function(delta){};
  prototype.render = function(ctx){
    if (this.absorbed) {
      return false;
    }
    if (this._radiusChanged) {
      this.radiusSmooth += 0.2 * (this._style.radius - this.radiusSmooth);
      if (Math.abs(this._style.radius - this.radiusSmooth < 0.01)) {
        this._radiusChanged = false;
      }
    }
    ctx.save();
    ctx.translate(this.x, this.y);
    ctx.beginPath();
    ctx.arc(0, 0, this.radiusSmooth, 0, 2 * Math.PI);
    ctx.fillStyle = this._style.bg;
    ctx.fill();
    ctx.scale(0.1, 0.1);
    ctx.font = (this._style.pt - 10 * (this._style.radius - this.radiusSmooth)) + "pt Courier";
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillStyle = this._style.fg;
    ctx.fillText(this.mass + "", 0, this.radiusSmooth);
    ctx.restore();
    if (ORB.DEBUG) {
      ctx.save();
      ctx.font = '8px Arial';
      ctx.fillStyle = 'white';
      ctx.fillText("(" + this.x + ", " + this.y + ")", this.x, this.y);
      ctx.restore();
    }
    return true;
  };
  return Planet;
}(ORB.Entity));
ORB.Player = Player = (function(superclass){
  var prototype = extend$((import$(Player, superclass).displayName = 'Player', Player), superclass).prototype, constructor = Player;
  function Player(scene){
    Player.superclass.call(this, scene, 0, 0, 2);
    this.keys = {
      w: false,
      a: false,
      s: false,
      d: false
    };
  }
  prototype.respawn = function(){
    this.keys.w = false;
    this.keys.a = false;
    this.keys.s = false;
    this.keys.d = false;
    this.x = 0;
    this.y = 0;
  };
  prototype.tick = function(delta){
    var moveSpeed;
    superclass.prototype.tick.apply(this, arguments);
    moveSpeed = 0.02 * (0.5 + 0.005 * this.mass);
    if (this.keys.w) {
      this.vy -= moveSpeed;
    }
    if (this.keys.a) {
      this.vx -= moveSpeed;
    }
    if (this.keys.s) {
      this.vy += moveSpeed;
    }
    if (this.keys.d) {
      this.vx += moveSpeed;
    }
    return true;
  };
  return Player;
}(ORB.Planet));
function extend$(sub, sup){
  function fun(){} fun.prototype = (sub.superclass = sup).prototype;
  (sub.prototype = new fun).constructor = sub;
  if (typeof sup.extended == 'function') sup.extended(sub);
  return sub;
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}