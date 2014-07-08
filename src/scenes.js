// Generated by LiveScript 1.2.0
var Scene, Space;
ORB.Scene = Scene = (function(){
  Scene.displayName = 'Scene';
  var prototype = Scene.prototype, constructor = Scene;
  function Scene(){
    this.entityManager = new ORB.EntityManager(this);
  }
  prototype.add = function(entity){
    return this.entityManager.add(entity);
  };
  prototype.mouseDown = function(x, y, event){};
  prototype.mouseMove = function(x, y){};
  prototype.mouseUp = function(x, y, event){};
  prototype.keyDown = function(code){};
  prototype.keyUp = function(code){};
  prototype.tick = function(delta){
    return this.entityManager.tick(delta);
  };
  prototype.render = function(ctx){
    return this.entityManager.render(ctx);
  };
  return Scene;
}());
ORB.Space = Space = (function(superclass){
  var prototype = extend$((import$(Space, superclass).displayName = 'Space', Space), superclass).prototype, constructor = Space;
  function Space(){
    var i$;
    Space.superclass.call(this);
    this.planets = [];
    this.camera = {
      zoom: 1,
      x: -400,
      y: -225,
      moveTowards: function(entity, speed){
        speed = speed || 0.1;
        speed /= 1 + this.zoom / 10;
        this.x += speed * (this.zoom * entity.x - this.x - 400);
        return this.y += speed * (this.zoom * entity.y - this.y - 225);
      },
      applyTransform: function(ctx){
        ctx.translate(-this.x, -this.y);
        return ctx.scale(this.zoom, this.zoom);
      }
    };
    this.add(this.player = new ORB.Player(this));
    for (i$ = 0; i$ < 10; ++i$) {
      this.add(new ORB.Planet(this, (Math.random() - 0.5) * 10, (Math.random() - 0.5) * 200, Math.random() > 0.66 ? 2 : 4));
    }
  }
  prototype.add = function(entity){
    superclass.prototype.add.apply(this, arguments);
    if (entity instanceof ORB.Planet) {
      return this.planets.push(entity);
    }
  };
  prototype.keyDown = function(code){
    if (code === 65 || code === 37) {
      return this.player.keys.a = true;
    } else if (code === 68 || code === 39) {
      return this.player.keys.d = true;
    } else if (code === 87 || code === 38) {
      return this.player.keys.w = true;
    } else if (code === 83 || code === 40) {
      return this.player.keys.s = true;
    }
  };
  prototype.keyUp = function(code){
    if (code === 65 || code === 37) {
      return this.player.keys.a = false;
    } else if (code === 68 || code === 39) {
      return this.player.keys.d = false;
    } else if (code === 87 || code === 38) {
      return this.player.keys.w = false;
    } else if (code === 83 || code === 40) {
      return this.player.keys.s = false;
    }
  };
  prototype.tick = function(delta){
    var i$, to$, i, planetA, j$, to1$, j, planetB, distX, distY, distSq, dist, unitX, unitY, mm, force, ref$, len$, planet, lresult$, inciX, inciY, dot, reflX, reflY, results$ = [];
    superclass.prototype.tick.apply(this, arguments);
    this.camera.moveTowards(this.player);
    this.camera.zoom = 1 + 9 * (1 - (this.player.radiusSmooth - 0.798) / 24.73);
    for (i$ = 0, to$ = this.planets.length; i$ < to$; ++i$) {
      i = i$;
      planetA = this.planets[i];
      for (j$ = i + 1, to1$ = this.planets.length; j$ < to1$; ++j$) {
        j = j$;
        planetB = this.planets[j];
        distX = planetB.x - planetA.x;
        distY = planetB.y - planetA.y;
        distSq = distX * distX + distY * distY;
        dist = Math.sqrt(distSq);
        unitX = distX / dist;
        unitY = distY / dist;
        mm = planetA.mass * planetB.mass;
        force = distX === 0
          ? 0
          : 0.001 * mm / distSq;
        planetA.fx += force * unitX;
        planetA.fy += force * unitY;
        planetB.fx -= force * unitX;
        planetB.fy -= force * unitY;
      }
    }
    for (i$ = 0, len$ = (ref$ = this.planets).length; i$ < len$; ++i$) {
      planet = ref$[i$];
      planet.prevX = planet.x;
      planet.prevY = planet.y;
      planet.vx += planet.fx;
      planet.vy += planet.fy;
      planet.x += planet.vx;
      planet.y += planet.vy;
      planet.fx = 0;
      planet.fy = 0;
    }
    for (i$ = 0, to$ = this.planets.length; i$ < to$; ++i$) {
      i = i$;
      lresult$ = [];
      planetA = this.planets[i];
      for (j$ = i + 1, to1$ = this.planets.length; j$ < to1$; ++j$) {
        j = j$;
        planetB = this.planets[j];
        if (planetA.collidesWith(planetB)) {
          inciX = planetA.x - planetA.prevX;
          inciY = planetA.y - planetA.prevY;
          distX = planetB.x - planetA.x;
          distY = planetB.y - planetA.y;
          dot = inciX * distX + inciY * distY;
          distSq = distX * distX + distY * distY;
          reflX = inciX - (2 * dot) * distX / distSq;
          reflY = inciY - (2 * dot) * distY / distSq;
          planetA.vx += reflX;
          planetA.vy += reflY;
          planetB.vx -= reflX;
          lresult$.push(planetB.vy -= reflY);
        }
      }
      results$.push(lresult$);
    }
    return results$;
  };
  prototype.render = function(ctx){
    ctx.save();
    this.camera.applyTransform(ctx);
    superclass.prototype.render.apply(this, arguments);
    return ctx.restore();
  };
  return Space;
}(ORB.Scene));
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