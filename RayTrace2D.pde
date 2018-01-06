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
import java.awt.Color;

int fps = 30;
float revs = TWO_PI/fps;
ArrayList<Block> blocks;
ArrayList<Emitter> emitters;
ArrayList<Wire> wires;
Emitter emitter0;
int T = 12;
int nFireworks = 3;
int fireworkNo = 0;
int seed = round(random(0,999999));
/*---------------------------------------------------------------
Setup
----------------------------------------------------------------*/

void setup(){
  //P3D renderer looked best in tests
  size(700,700, P3D);
  frameRate(fps);
  background(0);
  
  //use blendMode ADD for physical combination of ray colours
  //blendMode(ADD);
  
  blocks = new ArrayList<Block>();
  emitters = new ArrayList<Emitter>();
  wires = new ArrayList<Wire>();
  
  //make the blocks
  //loadBlocks(blocks);
  
  for(int i = 0; i < 0; i ++) {
    Emitter emitter = new Emitter(new PVector(0.5*width, 1.2*height), blocks);
    emitters.add(emitter);
    //emitter.addAttractor(new PVector(width/2, height/2));
    emitter.velocity.y = -1.2*height;
  }
  
  randomSeed(seed);
  
  //hour hand
  Wire w = new Wire();
  w.addPoint(width*0.5, height*0.5);
  w.addPoint(width*0.5, height*0.65);
  w.constructFromPoints();
  wires.add(w);
  
  //minute hand
  w = new Wire();
  w.addPoint(width*0.5, height*0.5);
  w.addPoint(width*0.5, height*0.8);
  w.constructFromPoints();
  wires.add(w);

  
}

/*---------------------------------------------------------------
Draw
----------------------------------------------------------------*/

void draw() {
  wires.get(0).lines.get(0).end.x= width/2 + height*0.15 * cos(revs*frameCount/12 -HALF_PI);
  wires.get(0).lines.get(0).end.y= width/2 + height*0.15 * sin(revs*frameCount/12 -HALF_PI);
  wires.get(0).lines.get(0).updateDirection();
  
  wires.get(1).lines.get(0).end.x= width/2 + height*0.3 * cos(revs*frameCount -HALF_PI);
  wires.get(1).lines.get(0).end.y= width/2 + height*0.3 * sin(revs*frameCount -HALF_PI);
  wires.get(1).lines.get(0).updateDirection();
  
  float hourAngle = atan2(wires.get(0).lines.get(0).direction.y, wires.get(0).lines.get(0).direction.x);
  if( frameCount %30 == 1) {
    int hour = floor( (hourAngle+HALF_PI+TWO_PI-TWO_PI/12) / (TWO_PI/12))%12 +1;
    colorMode(HSB);
    explode(new PVector(width/2 + width*0.15*cos(hourAngle), height/2 + width*0.15*sin(hourAngle)),
        color(hour*255.0/12.0, 255, 255), hour);
    colorMode(RGB);
  }
  
  //update
  for (Emitter emitter : emitters) {
    emitter.update();
    emitter.intensity = 0.9*emitter.intensity;
  }
  
  //remove dead
  for(int i = emitters.size()-1; i >= 0; i --) {
    if(emitters.get(i).intensity < 1.0) {
      emitters.remove(i);
    }
  }
    
  for(int n = 0; n < 1; n++) {
    background(0);
    blendMode(ADD);

    for(Wire w : wires) {
      w.display();
    }
    wires.get(1).displayRotationTrail(-revs*3, 40);
    
    for (Emitter emitter : emitters) {
      //emitter.blocks = blocks;
      emitter.reset();
      emitter.emitRadial(1100,0);
      //emitter.emitLaser(30,80,PI, 30);
      emitter.trace();
      emitter.displayRays();
      emitter.displayTrails(emitter.intensity*10, 1.0, 0);
      
      emitter.reset();
      emitter.emitRadial(200,0);
      emitter.trace();
      emitter.displayRays(color(255, 255, 255));
    }
    //addMist(4, 3.0, 0.05);
    if(frameCount <= 12*fps) {
      //saveFrame("frame-###_" + n + ".png");
    }

  }
}

/*---------------------------------------------------------------
Other Functions
----------------------------------------------------------------*/
void keyPressed() {
  if(key == 'p') {
    saveFrame("screenshot.png");
  }
}


//Rotate the point p about the point (x, y)
PVector rotateAboutPoint(PVector p, float x, float y) {
  PVector output = new PVector(0,0);
  output.x = cos(revs*frameCount) * (p.x-x) - sin(revs*frameCount) * (p.y-y) + y;
  output.y = sin(revs*frameCount) * (p.x-x) + cos(revs*frameCount) * (p.y-y) + y;
  return output;
}

PVector rotateAboutPoint(PVector p, float x, float y, float angle) {
  PVector output = new PVector(0,0);
  output.x = cos(angle) * (p.x-x) - sin(angle) * (p.y-y) + y;
  output.y = sin(angle) * (p.x-x) + cos(angle) * (p.y-y) + y;
  return output;
}

//Calculate the point from p, based on polar coordinates (r, theta)
PVector polarAboutPoint(PVector p, float r, float theta) {
  PVector output = new PVector(0,0);
  output.x = p.x + r*cos(theta);
  output.y = p.y + r*sin(theta);
  return output;
}

void addMist(float r, float T, float level) {
  float mistLevel;
  float dx = width * 0.00007;
  float dy = height * 0.00007;
  loadPixels();
  for(int x = 0; x < width; x++) {
    for(int y = 0; y < height; y++) {
      //position based, with time looping
      //mistLevel = noise(x*dx, y*dy, r*sin(revs*frameCount/T));
      mistLevel = 0.5*noise(x*dx + r*cos(revs*frameCount/T), y*dy + r*sin(revs*frameCount/T));
      mistLevel += 0.5*noise(100 +x*dx + r*sin(revs*frameCount/T), y*dy + r*cos(revs*frameCount/T));
      //subtract mist based on inverse brightness - brightest light stays shining through
      mistLevel *= level*255 * (1-brightness(pixels[y*width + x])/255.0);//(1-pow(brightness(pixels[y*width + x])/255.0, 2.1));
      pixels[y*width + x] = color(red(pixels[y*width + x])-mistLevel,
          green(pixels[y*width + x])-mistLevel,
          blue(pixels[y*width + x])-mistLevel);
    }
  }
  updatePixels();
}

void originalTestBlocks() {
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
}

void loadBlocks(ArrayList<Block> blocks) {
  String[] lines = loadStrings("points.txt");
  for(int i = 0; i < lines.length; i++) {
    
    //setup for new block
    String[] points = lines[i].split(",");
    ArrayList<PVector> blockPoints = new ArrayList<PVector>();
    
    //for each point to a block
    for(int j = 0; j < points.length; j++) {
      String[] coords = points[j].split(" ");
      blockPoints.add(new PVector(float(coords[0])*width, float(coords[1])*height));
    }
    
    Block b = new Block(blockPoints);
    blocks.add(b);
    blockPoints.clear();
  }
}

//attack-sustain-decay waveform, periodic in T, using time variable t
//first 3 variables normalised such that 1 = T
float envelope(float attack, float sustain, float decay, float t, float T) {
  float time = (t%T)/T;
  if(time <= attack) {
    //linear ramp up
    return time/attack;
  } else if(time <= (attack + sustain)) {
    //flat
    return 1;
  } else if(time <= (attack + sustain + decay)) {
    //linear ramp down
    return 1 - ((time-attack-sustain)/decay);
  } else {
    //off
    return 0;
  }
}