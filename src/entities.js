// Generated by LiveScript 1.2.0
var EntityManager, Entity, Planet, Player;
ORB.EntityManager = EntityManager = (function(){
  EntityManager.displayName = 'EntityManager';
  var prototype = EntityManager.prototype, constructor = EntityManager;
  function EntityManager(scene){
    this.scene = scene;
    this.tickQueue = new List();
    this.renderQueue = new List();
    this.tangibleList = new List();
  }
  prototype.add = function(entity){
    if ('tick' in entity) {
      this.tickQueue.add(entity);
    }
    if ('render' in entity) {
      this.renderQueue.add(entity);
    }
    if (entity.mass > 0) {
      return this.tangibleList.add(entity);
    }
  };
  prototype.tick = function(delta){
    var i$, to$, i, entity, results$ = [];
    for (i$ = 0, to$ = this.tickQueue.size; i$ < to$; ++i$) {
      i = i$;
      entity = this.tickQueue.poll();
      results$.push(entity.tick(delta) && this.tickQueue.add(entity));
    }
    return results$;
  };
  prototype.render = function(ctx){
    var i$, to$, i, entity, results$ = [];
    for (i$ = 0, to$ = this.renderQueue.size; i$ < to$; ++i$) {
      i = i$;
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
  var radiusChanged, prototype = extend$((import$(Planet, superclass).displayName = 'Planet', Planet), superclass).prototype, constructor = Planet;
  Planet.styles = {
    2: {
      fg: '#776e65',
      bg: '#eee4da'
    },
    4: {
      fg: '#776e65',
      bg: '#ede0c8'
    },
    8: {
      fg: '#f9f6f2',
      bg: '#f2b179'
    },
    16: {
      fg: '#f9f6f2',
      bg: '#f59563'
    },
    32: {
      fg: '#f9f6f2',
      bg: '#f67c5f'
    },
    64: {
      fg: '#f9f6f2',
      bg: '#f65e3b'
    },
    128: {
      fg: '#f9f6f2',
      bg: '#edcf72'
    },
    256: {
      fg: '#f9f6f2',
      bg: '#edcc61'
    },
    512: {
      fg: '#f9f6f2',
      bg: '#edc850'
    },
    1024: {
      fg: '#f9f6f2',
      bg: '#edc53f'
    },
    2048: {
      fg: '#f9f6f2',
      bg: '#edc22e'
    }
  };
  function Planet(scene, x, y, mass){
    this.mass = mass;
    Planet.superclass.call(this, scene, x, y);
    this.radius = Math.sqrt(mass / Math.PI);
  }
  radiusChanged = false;
  Object.defineProperty(prototype, 'mass', {
    get: function(){
      return this._mass;
    },
    set: function(mass){
      this._mass = mass;
      this.radius = Math.sqrt(mass / Math.PI);
      radiusChanged = true;
    },
    configurable: true,
    enumerable: true
  });
  prototype.tick = function(delta){};
  prototype.render = function(){
    var radiusSmooth, smoothRadius;
    radiusSmooth = 0;
    smoothRadius = function(it){
      radiusSmooth += 0.2 * (it - radiusSmooth);
      if (Math.abs(it - radiusSmooth < 0.01)) {
        radiusChanged = false;
      }
    };
    return function(ctx){
      var rScaled;
      if (radiusChanged) {
        smoothRadius(this.radius);
      }
      rScaled = radiusSmooth * 10;
      ctx.save();
      ctx.beginPath();
      ctx.arc(this.x, this.y, rScaled, 0, 2 * Math.PI);
      ctx.fillStyle = constructor.styles[this.mass].bg;
      ctx.fill();
      ctx.font = rScaled * 1.33 + "pt Thaoma";
      ctx.textAlign = 'center';
      ctx.fillStyle = constructor.styles[this.mass].fg;
      ctx.fillText(this.mass + "", this.x, this.y + rScaled * 0.66);
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
  }();
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
    moveSpeed = 4;
    if (this.keys.w) {
      this.y -= moveSpeed;
    }
    if (this.keys.a) {
      this.x -= moveSpeed;
    }
    if (this.keys.s) {
      this.y += moveSpeed;
    }
    if (this.keys.d) {
      this.x += moveSpeed;
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