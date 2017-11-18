/*---------------------------------------------------------------
Particle
A point particle that obeys some basic physics
----------------------------------------------------------------*/

class Particle {
  PVector position;
  PVector velocity;
  float dt = 1/float(fps);
  ArrayList<Block> blocks;
  float size;
  
  /*---------------------------------------------------------------
  Init
  ----------------------------------------------------------------*/
  Particle() {
    velocity = new PVector(0,0);
    size = 1.2;
  }
  
  /*---------------------------------------------------------------
  Motion/Physics
  ----------------------------------------------------------------*/
  //calculate the line segment of the next trajectory
  Line getNextPath() {
    return new Line(position, PVector.add(position, velocity.copy().mult(dt)));
  }
  
  //apply acceleration of the particle, and update position/velocity
  //this takes into account any collisions that may happen
  void update() {
    accelerate();
    
    Line path = getNextPath();
    Line obstacle = path.closestIntercept(blocks);
    
    PVector intercept;
    PVector direction;
    float distanceLeft = path.direction.mag();
    
    //handle collisions
    while(obstacle != null) {
      //get intercept point
      intercept = path.getIntersect(obstacle).sub(path.direction.copy().normalize().mult(size));
      //get new vector direction
      direction = path.getReflection(obstacle).normalize();
      //include a coefficient of restitution
      velocity = PVector.mult(direction, velocity.mag()).mult(0.85);
      //calculate new path
      distanceLeft -= PVector.sub(intercept, path.start).mag();
      path = new Line(PVector.add(intercept, direction.mult(0.1+size)), PVector.add(intercept, direction.mult(1/(0.1+size)).mult(distanceLeft)));
      //test collision
      obstacle = path.closestIntercept(blocks);
    }
    
    //no more collisions!
    //print(velocity.mag() + " ");
    position = path.end;
  }
  
  void updateNoCollisions() {
    accelerate();
    
    Line path = getNextPath();

    position = path.end;
  }
  
  void accelerate() {
    PVector a = new PVector(0,0);
    //add gravity:
    float gravity = height*0.6;
    a.y += dt*gravity;
    
    //air resistance
    float terminalVelocity = height*0.6;
    a.sub(velocity.copy().mult(dt*gravity/terminalVelocity));
    
    velocity.add(a);
  }
  
}