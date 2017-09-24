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
  
  //points.clear();
  //points.add(new PVector(0, 0));
  //points.add(new PVector(width, 0));
  //points.add(new PVector(width, height));
  //points.add(new PVector(0, height));
  //b = new Block(points);
  //blocks.add(b);
  
  emitter = new Emitter(new PVector(width/2, height/2));
  emitter2 = new Emitter(new PVector(width/2, height/2));
  emitter3 = new Emitter(new PVector(width/2, height/2));
}

/*---------------------------------------------------------------
Draw
----------------------------------------------------------------*/

void draw() {
  background(0);
  
  for(Block b : blocks) {
    //b.display();
  }
  
  //emitter.position.y = height/2 + 70*sin(revs*frameCount);
  emitter.position.x = width/2 + map(sin(revs*frameCount),-1,1,0,width/10);
  emitter.position.y = height/2 + map(sin(revs*frameCount),-1,1,0,width/10);
  emitter.position = rotateAboutPoint(emitter.position, width/2, height/2);
  emitter.reset();
  emitter.emitRadial(6000, 1);
  emitter.trace(blocks);
  emitter.displayRays(color(255,0,0,3));
  
  emitter2.position.x = width/2;
  emitter2.position.y = height/2 - map(sin(revs*frameCount),-1,1,0,width/10);
  emitter2.position = rotateAboutPoint(emitter2.position, width/2, height/2);
  emitter2.reset();
  emitter2.emitRadial(6000, 1);
  emitter2.trace(blocks);
  emitter2.displayRays(color(0,255,0,3));
  
  emitter3.position.x = width/2 - map(sin(revs*frameCount),-1,1,0,width/10);
  emitter3.position.y = height/2 + map(sin(revs*frameCount),-1,1,0,width/10);
  emitter3.position = rotateAboutPoint(emitter3.position, width/2, height/2);
  emitter3.reset();
  emitter3.emitRadial(6000, 1);
  emitter3.trace(blocks);
  emitter3.displayRays(color(0,0,255,3));
  
  if(frameCount <= fps) {
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