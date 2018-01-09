/*---------------------------------------------------------------
Wire
A set of Line that also glows
----------------------------------------------------------------*/

class Wire{
  float glowLevel;
  float thickness;
  ArrayList<Line> lines;
  ArrayList<PVector> points;
  color col;
  
  /*---------------------------------------------------------------
  Init
  ----------------------------------------------------------------*/
  Wire() {
    glowLevel = 5.0;
    thickness = 0.0;
    lines = new ArrayList<Line>();
    points = new ArrayList<PVector>();
    col = color(255);
  }
  
  Wire(float g) {
    glowLevel = g;
    thickness = 0.0;
    lines = new ArrayList<Line>();
    points = new ArrayList<PVector>();
  }
  
  /*---------------------------------------------------------------
  Construction
  ----------------------------------------------------------------*/
  void addSegment(PVector p1, PVector p2) {
    lines.add(new Line(p1, p2));
  }
  
  void addPoint(float x, float y) {
    points.add(new PVector(x, y));
  }
  
  void constructFromPoints() {
    for(int i = 0; i < points.size()-1; i++) {
      addSegment(points.get(i), points.get(i+1));
    }
  }
  
  /*---------------------------------------------------------------
  Motion
  ----------------------------------------------------------------*/
  void rotateBy(float theta) {
    for(Line l : lines) {
      l.start = rotateAboutPoint(l.start, points.get(0).x, points.get(0).y, theta);
      l.end = rotateAboutPoint(l.end, points.get(0).x, points.get(0).y, theta);
      l.updateDirection();
    }
  }
  
  /*---------------------------------------------------------------
  Display
  ----------------------------------------------------------------*/
  void display() {
    noFill();
    rectMode(CENTER);
    for(Line l : lines) {
      float theta = atan2(l.direction.y, l.direction.x);
      
      for(int i = -round(30); i < 30; i++) {
        float j;
        
        if(abs(i) <= thickness) {
          j = 255;
        } else {
          j = 255.0 * glowLevel / ( (abs(i)-thickness)*(abs(i)-thickness));
        } 
        
        stroke(hue(col), saturation(col),brightness(col),j);
        strokeWeight(1);
        line(l.start.x - i*sin(theta), l.start.y + i*cos(theta),
          l.end.x - i*sin(theta), l.end.y + i*cos(theta));
        
        if(i >= 0) {
          ellipseMode(CENTER);
          stroke(hue(col), saturation(col),brightness(col),j);
          strokeWeight(1);
          //ellipse(l.start.x, l.start.y, 2*i, 2*i);
          //ellipse(l.end.x, l.end.y, 2*i, 2*i);
          arc(l.start.x, l.start.y, 2*i, 2*i, theta+HALF_PI, theta+3*HALF_PI, OPEN);
          arc(l.end.x, l.end.y, 2*i, 2*i, theta-HALF_PI, theta+HALF_PI, OPEN);
        }
        
      }
      
    }
  }
  
  void displayRotationTrail(float angle, int ghosts) {
    float theta = angle / ghosts;
    Wire w = new Wire();
    for(PVector p : points) {
      w.points.add(p.copy());
    }
    for(Line l : lines) {
      w.lines.add(l.copy());
    }
    //w.col = col;
    float v = 50.0;
    for(int i = 1; i <= ghosts; i++) {
      w.col = color(hue(col), saturation(col),v - v/ghosts*i);
      w.rotateBy(theta);
      w.display();
    }
  }
}