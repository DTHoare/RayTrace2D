/*---------------------------------------------------------------
Ray
A ray of light. Consists of a series of lines, that can be traced
when given a set of objects to interact with
----------------------------------------------------------------*/

class Ray {
  ArrayList<Line> lines;
  ArrayList<Float> bValues; //brightness of each ray line
  int bounces;
  PVector origin;
  PVector direction;
  
  /*---------------------------------------------------------------
  Init
  ----------------------------------------------------------------*/
  
  Ray(PVector origin_, PVector direction_, int bounces_) {
    lines = new ArrayList<Line>();
    bValues = new ArrayList<Float>();
    bounces = bounces_;
    origin = origin_.copy();
    //start with line 'infinitely' long
    direction = direction_.copy().normalize().mult(width+height);
  }
  
  /*---------------------------------------------------------------
  Tracing
  ----------------------------------------------------------------*/
  
  void trace(ArrayList<Block> blocks) {
    //calculate initial start and end points for first line
    PVector start = origin.copy();
    PVector end = PVector.add(origin,direction);
    float brightness = 0.3;
    
    for(int i = 0; i <= bounces; i++) {
      //reset test line and associated values
      Line l = new Line(start, end);
      Surface reflector = null;
      PVector point = end.copy();

      reflector = l.closestIntercept(blocks);
      if(reflector != null) {
        point = l.getIntersect(reflector);
      }
      
      //add the line generated from the closest intersection (or original point if none)
      l = new Line(start, point);
      lines.add(l);
      bValues.add(brightness);
      
      //no collision, end here
      if(reflector == null) {
        return;
      }
      
      //reduce brightness based on the albedo value of the surface
      brightness *= reflector.albedo;
      
      
      //reset the start and end to the new values given by the end of the previous line
      //and the direction from the reflection
      //stop problems of starting at a surface by moving a small distance away from the surface
      PVector reflectionNorm = l.getReflection(reflector).normalize();
      start = PVector.add(point, reflectionNorm.mult(0.1));
      end = PVector.add(start, reflectionNorm.mult(10).mult(width+height));
    }

  }
  
  /*---------------------------------------------------------------
  Display
  ----------------------------------------------------------------*/
  void display() {
    for(int i = 0; i < lines.size(); i++) {
      lines.get(i).display(bValues.get(i));
    }
  }
}