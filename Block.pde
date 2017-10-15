/*---------------------------------------------------------------
Block
Physical objects that are opaque. Made from a collection of lines
and points.

Possible upgrades:
-initialise from PShape
-contain reflective/refractive properties
-builder options
----------------------------------------------------------------*/

class Block{
  ArrayList<PVector> points;
  ArrayList<Surface> surfaces;
  
  /*---------------------------------------------------------------
  Init
  ----------------------------------------------------------------*/

  Block(ArrayList<PVector> ps){
    points = new ArrayList<PVector>();
    //make sure new instances are created, not just reference passing
    for(PVector p : ps) {
      PVector P = p.copy();
      points.add(P);
    }
    surfaces = new ArrayList<Surface>();
    calculateLines();
  }
  
  //turn a set of points into a set of line segments
  void calculateLines() {
    for(int i = 0; i < points.size(); i++) {
      Surface s = new Surface(points.get(i), points.get((i+1)%points.size()), 0.8, 0.0);
      surfaces.add(s);
    }
  }
  
  /*---------------------------------------------------------------
  Math
  ----------------------------------------------------------------*/
  
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