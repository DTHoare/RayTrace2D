/*---------------------------------------------------------------
Block
Physical objects that are opaque. Made from a collection of lines
and points.

Possible upgrades:
-initialise from PShape
-contain reflective/refractive properties
-builder options
----------------------------------------------------------------*/

class Block extends Particle{
  ArrayList<PVector> points;
  ArrayList<PVector> points_origin;
  ArrayList<Surface> surfaces;
  
  /*---------------------------------------------------------------
  Init
  ----------------------------------------------------------------*/

  Block(ArrayList<PVector> ps){
    points = new ArrayList<PVector>();
    points_origin = new ArrayList<PVector>();
    //make sure new instances are created, not just reference passing
    for(PVector p : ps) {
      PVector P = p.copy();
      points.add(P);
      points_origin.add(p.copy());
    }
    surfaces = new ArrayList<Surface>();
    calculateLines();
    velocity = new PVector(0,0);
    position = new PVector(0,0);
  }
  
  //turn a set of points into a set of line segments
  void calculateLines() {
    for(int i = 0; i < points.size(); i++) {
      Surface s = new Surface(points.get(i), points.get((i+1)%points.size()), 0.1, 0.0);
      surfaces.add(s);
    }
  }
  
  /*---------------------------------------------------------------
  Math
  ----------------------------------------------------------------*/
  
  //update positions of all points based on gravity 
  void update() {
    position.x = 0;
    position.y = 0;
    
    accelerate();
    
    Line path = getNextPath();

    position = path.end;
    
    for(PVector p : points) {
      p.x += position.x;
      p.y += position.y;
    }
    
    surfaces.clear();
    calculateLines();
  }
  
  //update position based on x, y
  void updatePosition(float x, float y) {
    for(PVector p : points) {
      p.x += x;
      p.y += y;
    }
    
    surfaces.clear();
    calculateLines();
  }
  
  void setPosition(float x, float y) {
    PVector p;
    PVector pi;
    for(int i = 0; i < points.size(); i++) {
      p = points.get(i);
      pi = points_origin.get(i);
      p.x = pi.x + x;
      p.y = pi.y + y;
    }
    
    surfaces.clear();
    calculateLines();
  }
  
  void updateVelocity(float x, float y) {
    velocity.x += x;
    velocity.y += y;
    Line path = getNextPath();

    position = path.end;
    
    for(PVector p : points) {
      p.x += position.x;
      p.y += position.y;
    }
    
    surfaces.clear();
    calculateLines();
  }
  
  /*---------------------------------------------------------------
  Display
  ----------------------------------------------------------------*/
  void display() {
    fill(255);
    for(PVector p : points){
      ellipse(p.x, p.y, 5, 5);
    }
    for(Surface s : surfaces) {
      s.display();
    }
  }
  
}

//create walls around the borders of the canvas
Block makeBorders() {
  ArrayList<PVector> points = new ArrayList<PVector>();
  points.clear();
  points.add(new PVector(0, 0));
  points.add(new PVector(width, 0));
  points.add(new PVector(width, height));
  points.add(new PVector(0, height));
  return new Block(points);
}

//make a disk composed of n surfaces, about (x, y) with radius r
Block makeDisk(float x, float y, float r, int n) {
  
  ArrayList<PVector> points = new ArrayList<PVector>();
  float theta;
  
  for(int i = 0; i < n; i++) {
    theta = i * TWO_PI / n;
    points.add(new PVector(x + r * cos(theta), y + r * sin(theta)));
  }
  return new Block(points);
}