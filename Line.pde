/*---------------------------------------------------------------
Line
A line describes by a start location and a direction, line = X + D
Provides math for collision detection
----------------------------------------------------------------*/

class Line {
  PVector start;
  PVector end;
  PVector direction;
  
  /*---------------------------------------------------------------
  Init
  ----------------------------------------------------------------*/
  Line(PVector p1, PVector p2){
    start = p1.copy();
    end = p2.copy();
    direction = PVector.sub(p2, p1);
  }
  
  /*---------------------------------------------------------------
  Math
  
  Geometry results taken from here:
  https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
  ----------------------------------------------------------------*/
  
  //2D cross product for geometry
  float cross(PVector p1, PVector p2) {
    return p1.x * p2.y - p1.y * p2.x;
  }
  
  //Check if this line intersects with another
  boolean intersects(Line l){
    float directionCross = cross(direction, l.direction);
    if(directionCross == 0) {
      //parallel 
      return false;
    }
    
    PVector startSub = PVector.sub(l.start, start);
    float t = cross(startSub, l.direction) / directionCross;
    float u = cross(startSub, direction) / directionCross;
    
    //include a bias for interception
    if( (t >= 0 && t <= 1.00001) && (u >= 0 && u <= 1.00001) ) {
      return true;
    }
    return false;
  }
  
  //calculate the point of intersection between this line and another
  //untested for lines that aren't intersecting - will likely extrapolate line segment to infinity
  PVector getIntersect(Line l){
    float directionCross = cross(direction, l.direction);
    PVector startSub = PVector.sub(l.start, start);
    float t = cross(startSub, l.direction) / directionCross;
    return new PVector(start.x + t*direction.x, start.y + t * direction.y);
  }
  
  //https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
  //Test whether the point p is within distance maxError of this line
  boolean containsPoint(PVector p, float maxError) {
    float l2 = direction.magSq();
    float t = max(0, min(1, PVector.dot( PVector.sub(p, start), direction)/l2));
    PVector projection =  PVector.add(start,direction.mult(t));
    if ( PVector.sub(p, projection).magSq() < maxError*maxError) {
      return true;
    } else {
      return false;
    }
  }
  
  //returns new direction vector after reflection from line l
  //http://paulbourke.net/geometry/reflected/
  PVector getReflection(Line l) {
    //normal vector:
    PVector N = new PVector(-1*l.direction.y, l.direction.x).normalize();
    //incident normalised
    PVector Inorm = direction.copy().normalize();
    float IN = PVector.dot(Inorm, N);
    return PVector.sub(Inorm, N.mult(2*IN));
  }
  
  //advanced case for surfaes, allows diffuse reflection
  PVector getReflection(Surface l) {
    float random = random(0,1);
    
    //specular
    if(random > l.diffusivity) { 
      //normal vector:
      PVector N = new PVector(-1*l.direction.y, l.direction.x).normalize();
      //incident normalised
      PVector Inorm = direction.copy().normalize();
      float IN = PVector.dot(Inorm, N);
      return PVector.sub(Inorm, N.mult(2*IN));
    } else {
      //diffuse
      //TODO: Fix - this method does not work!
      PVector N = new PVector(-1*l.direction.y, l.direction.x).normalize();
      PVector Inorm = direction.copy().normalize();
      float IN = PVector.dot(Inorm, N);
      //reflect at any angle away from normal
      return (N.mult(-2*IN).rotate(random(-PI/4, PI/4)));
    }
    
  }
  
  Surface closestIntercept(ArrayList<Block> blocks) {
    Surface closestIntercept = null;
    PVector trialPoint;
    PVector point = end.copy();
    
    for(Block b : blocks) {
      for(Surface lb : b.surfaces) {
        
        //check intersecton of the ray line with the block line
        if(intersects(lb)) {
          trialPoint = getIntersect(lb);
          //test to see whether the intersection is closer than the curent ray end point
          //if it is: update and record which block line this interacts with
          if( PVector.sub(start, trialPoint).magSq() < PVector.sub(start, point).magSq() ) {
            point = trialPoint.copy();
            closestIntercept = new Surface(lb.start, lb.end, lb.albedo, lb.diffusivity);
          }
          
        }
      }
    }
    
    return closestIntercept;
  }
  
  /*---------------------------------------------------------------
  Display
  ----------------------------------------------------------------*/
  void display() {
    stroke(255, 3);
    line(start.x, start.y, start.x + direction.x, start.y + direction.y);
  }
  
  void display(float b) {
    stroke(255, b);
    line(start.x, start.y, start.x + direction.x, start.y + direction.y);
  }
}