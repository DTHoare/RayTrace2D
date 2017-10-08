/*---------------------------------------------------------------
Emitter
A light source, that emits a collection of rays
----------------------------------------------------------------*/

class Emitter extends Particle {
  ArrayList<Ray> rays;
  float intensity;
  
  /*---------------------------------------------------------------
  Init
  ----------------------------------------------------------------*/
  Emitter(PVector pos, ArrayList<Block> blocks_) {
    position = pos.copy();
    rays = new ArrayList<Ray>();
    blocks = blocks_;
    intensity = 2;
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
    for(Ray r : rays) {
      r.display();
    }
  }
  
  //display the rays with a low opacity, so that overlapping rays give
  //rise to physical fall off (using photon model of light intensity)
  void displayRays(color c) {
    PShape lines = createShape();
    lines.beginShape(LINES);
    color c_ = color(red(c), blue(c), green(c), intensity);
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
}