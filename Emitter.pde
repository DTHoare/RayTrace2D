/*---------------------------------------------------------------
Emitter
A light source, that emits a collection of rays
----------------------------------------------------------------*/

class Emitter {
  ArrayList<Ray> rays;
  PVector position;
  
  /*---------------------------------------------------------------
  Init
  ----------------------------------------------------------------*/
  Emitter(PVector pos) {
    position = pos.copy();
    rays = new ArrayList<Ray>();
  }
  
  void reset() {
    rays.clear();
  }
  
  /*---------------------------------------------------------------
  Emission
  ----------------------------------------------------------------*/
  
  //emit a Ray in the direction of each node within the set of blocks
  void emitNodes(ArrayList<Block> blocks) {
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
  void trace(ArrayList<Block> blocks) {
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
    lines.stroke(c);
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