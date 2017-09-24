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
  ArrayList<Line> lines;
  
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
    lines = new ArrayList<Line>();
    calculateLines();
  }
  
  //turn a set of points into a set of line segments
  void calculateLines() {
    for(int i = 0; i < points.size(); i++) {
      Line l = new Line(points.get(i), points.get((i+1)%points.size()));
      lines.add(l);
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
    for(Line l : lines) {
      l.display();
    }
  }
  
}