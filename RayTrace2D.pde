/*---------------------------------------------------------------
Daniel Hoare 2017

Base system based on: http://ncase.me/sight-and-light/

Blocks represent opaque, reflective objects, Rays are light rays. Both
are comprised of a set of lines, which are vector representation of
line segments, and perform collision testing.
An Emitter object produces rays, and sets them to trace the scene.

TODO:
-tidy up initialisation 
-methods for creating certain block shapes
-more physics effects
-post-processing style effects
----------------------------------------------------------------*/
int fps = 30;
float revs = TWO_PI/fps;
ArrayList<Block> blocks;
Emitter emitter;
Emitter emitter2;
Emitter emitter3;

/*---------------------------------------------------------------
Setup
----------------------------------------------------------------*/

void setup(){
  //P3D renderer looked best in tests
  size(500,500, P3D);
  frameRate(fps);
  //use blendMode ADD for physical combination of ray colours
  blendMode(ADD);
  
  blocks = new ArrayList<Block>();
  
  //make the blocks
  ArrayList<PVector> points = new ArrayList<PVector>();

  //top block
  PVector centre = new PVector(width/2, 0.2*height);
  points.add(polarAboutPoint(centre,width*0.09,0.85*TWO_PI));
  points.add(polarAboutPoint(centre,width*0.1,0.1*TWO_PI));
  points.add(polarAboutPoint(centre,width*0.08,0.5*TWO_PI));
  Block b = new Block(points);
  blocks.add(b);
  points.clear();
  
  //bottom block
  centre = new PVector(width*0.4, 0.7*height);
  points.add(polarAboutPoint(centre,width*0.28,0.6*TWO_PI));
  points.add(polarAboutPoint(centre,width*0.06,0.1*TWO_PI));
  points.add(polarAboutPoint(centre,width*0.1,0.4*TWO_PI));
  b = new Block(points);
  blocks.add(b);
  points.clear();
  
  //right block
  centre = new PVector(width*0.6, 0.8*height);
  points.add(polarAboutPoint(centre,width*0.21,0.45*TWO_PI));
  points.add(polarAboutPoint(centre,width*0.08,0.8*TWO_PI));
  points.add(polarAboutPoint(centre,width*0.1,0.9*TWO_PI));
  points.add(polarAboutPoint(centre,width*0.1,0.2*TWO_PI));
  b = new Block(points);
  blocks.add(b);
  points.clear();
  
  emitter = new Emitter(new PVector(width/2, -0.1*height), blocks);
  emitter.velocity.y = height*0.2;
}

/*---------------------------------------------------------------
Draw
----------------------------------------------------------------*/

void draw() {
  background(0);
  
  for(Block b : blocks) {
    //b.display();
  }
  
  emitter.reset();
  emitter.update();
  emitter.emitRadial(6000, 1);
  emitter.trace();
  emitter.displayRays(color(255,255,255,2));
  
  if(frameCount <= 6*fps) {
    //saveFrame("frame-###.png");
  }
}

/*---------------------------------------------------------------
Other Functions
----------------------------------------------------------------*/

//Rotate the point p about the point (x, y)
PVector rotateAboutPoint(PVector p, float x, float y) {
  PVector output = new PVector(0,0);
  output.x = cos(revs*frameCount) * (p.x-x) - sin(revs*frameCount) * (p.y-y) + y;
  output.y = sin(revs*frameCount) * (p.x-x) + cos(revs*frameCount) * (p.y-y) + y;
  return output;
}

//Calculate the point from p, based on polar coordinates (r, theta)
PVector polarAboutPoint(PVector p, float r, float theta) {
  PVector output = new PVector(0,0);
  output.x = p.x + r*cos(theta);
  output.y = p.y + r*sin(theta);
  return output;
}

void originalTestBlocks() {
  ArrayList<PVector> points = new ArrayList<PVector>();
  points.add(new PVector(0.7*width, 0.7*height));
  points.add(new PVector(0.8*width, 0.6*height));
  points.add(new PVector(0.67*width, 0.7*height));
  points.add(new PVector(0.7*width, 0.8*height));
  Block b = new Block(points);
  blocks.add(b);
  
  points.clear();
  points.add(new PVector(0.3*width, 0.1*height));
  points.add(new PVector(0.4*width, 0.3*height));
  points.add(new PVector(0.67*width, 0.2*height));
  points.add(new PVector(0.5*width, 0.15*height));
  b = new Block(points);
  blocks.add(b);
  
  points.clear();
  points.add(new PVector(0.1*width, 0.4*height));
  points.add(new PVector(0.2*width, 0.5*height));
  points.add(new PVector(0.45*width, 0.9*height));
  points.add(new PVector(0.15*width, 0.6*height));
  b = new Block(points);
  blocks.add(b);
}