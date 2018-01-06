/*---------------------------------------------------------------
Emitter
A light source, that emits a collection of rays
----------------------------------------------------------------*/

class Emitter extends Particle {
  ArrayList<Ray> rays;
  float intensity;
  color col;
  
  /*---------------------------------------------------------------
  Init
  ----------------------------------------------------------------*/
  Emitter(PVector pos, ArrayList<Block> blocks_) {
    position = pos.copy();
    rays = new ArrayList<Ray>();
    blocks = blocks_;
    intensity = 2;
    col = color(255);
    history = 0;
  }
  
  void reset() {
    rays.clear();
  }
  /*---------------------------------------------------------------
  Physics
  ----------------------------------------------------------------*/
  
  /*---------------------------------------------------------------
  Emission
  ----------------------------------------------------------------*/
  
  //emit a Ray in the direction of each node within the set of blocks
  void emitNodes() {
    Ray r;
    PVector direction;
    for(Block b : blocks) {
      for(PVector p : b.points) {
        direction = PVector.sub(p, position);
        r = new Ray(position, direction, 1);
        rays.add(r);
      }
    }
  }
  
  //emit n Rays, evenly spaced in angle
  void emitRadial(int n, int reflections) {
    float dtheta = TWO_PI/n;
    Ray r;
    for(int i = 0; i<n; i++) {
       r = new Ray(position, new PVector(cos(i*dtheta), sin(i*dtheta)), reflections);
       rays.add(r);
    }
  }
  
  void emitLaser(int n, int reflections, float angle, float w) {
    Ray r;
    PVector p;
    for(int i = 0; i<n; i++) {
      p = position.copy().add( (-w/2 + i * w/n)*sin(angle), (-w/2 + i * w/n)*cos(angle) );
       r = new Ray(p, new PVector(cos(angle), sin(angle)), reflections);
       rays.add(r);
    }
  }
  
  /*---------------------------------------------------------------
  Trace
  ----------------------------------------------------------------*/
  void trace() {
    for(Ray r : rays) {
      r.trace(blocks);
    }
  }
  
  /*---------------------------------------------------------------
  Display
  ----------------------------------------------------------------*/
  void displayRays() {
    color c = col;
    PShape lines = createShape();
    lines.beginShape(LINES);
    color c_ = color(red(c), green(c), blue(c), intensity);
    lines.stroke(c_);
    for(Ray r : rays) {
      for(Line l : r.lines) {
        lines.vertex(l.start.x, l.start.y);
        lines.vertex(l.end.x,l.end.y);
      }
    }
    lines.endShape();
    shape(lines);
  }
  
  //display the rays with a low opacity, so that overlapping rays give
  //rise to physical fall off (using photon model of light intensity)
  void displayRays(color c) {
    PShape lines = createShape();
    lines.beginShape(LINES);
    color c_ = color(red(c), green(c), blue(c), intensity);
    lines.stroke(c_);
    for(Ray r : rays) {
      for(Line l : r.lines) {
        lines.vertex(l.start.x, l.start.y);
        lines.vertex(l.end.x,l.end.y);
      }
    }
    lines.endShape();
    shape(lines);
  }
  
  void displayTrails(float n, float intensity, float jitter) {
    if(history == 0 || previousPositions.size() < 2) {
      return;
    }
    
    for(int i = 1; i < previousPositions.size(); i++) {
      PVector pa = previousPositions.get(i);
      PVector pb = previousPositions.get(i-1);
      for(int j = 0; j < n * (i+1+(history-previousPositions.size() )); j++) {
        //PVector p2 = new PVector(random(pb.x, pa.x) + random(-1,1)*jitter,
        //  random(pb.y, pa.y)+ random(-1,1)*jitter);
        //ellipse(p2.x, p2.y, 4, 4);
        PVector p2 = PVector.sub(pa, pb);
        
        color c_ = color(red(col), green(col), blue(col), 1);
        stroke(c_);
        line(pb.x, pb.y, pb.x+p2.x, pb.y+p2.y);
        
      }
    }
    
  }
}

void explode(PVector pos, color col, int n) {
  for(int i = 0; i < n; i++) {
      Emitter emitter = new Emitter(pos, blocks);
      emitter.col = col;
      emitter.intensity = random(12.0,15.0);
      emitter.setHistory(5);
      emitters.add(emitter);
      //float theta = random(0, TWO_PI);
      float theta = PI/(n+1) * (i+1) - PI + n*TWO_PI/12.0;
      float r = 0.6;
      //if(random(1) < 0.5) {r = random(-1.0,-0.5);} else {r = random(0.5,1.0);}
      r = r*height;
      emitter.velocity.y = r * sin(theta);
      emitter.velocity.x = r * cos(theta);
    }
}

void explodeCentre(PVector pos) {
  for(int i = 0; i < random(30,40); i++) {
      Emitter emitter = new Emitter(pos, blocks);
      emitter.col = color(255,0,255);
      emitter.intensity = random(1.0, 1.4);
      //emitter.setHistory(3);
      emitters.add(emitter);
      float theta = random(0, TWO_PI);
      float r = random(-0.3,0.3)*height;
      emitter.velocity.y = r * sin(theta);
      emitter.velocity.x = r * cos(theta);
    }
}