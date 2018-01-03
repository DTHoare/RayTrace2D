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
Emitter emitter0;
int T = 4;
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
  
  //make the blocks
  //loadBlocks(blocks);
  //blocks.add(makeSphericalMirror(width/4 + width/20, height/2, width/10, 300, 2*PI * 0.4, 2*PI * 0.6));
  //blocks.add(makeSphericalMirror(3*width/4, height/2, width/20, 300, 3*PI/2, PI/2));
  
  //blocks.add(makeMirror(width/4, height/2, height/4, PI/2));
  //blocks.add(makeDisk(width/2, height/2, width/20, 8));
  //blocks.get(0).setRotation(TWO_PI/16, width/2, height/2);
  //blocks.add(makeMirror(3*width/4, height/2, height/4, PI/2));
  //blocks.add(makeSphericalMirror(width/4 + width/45, height/2, width/2, 500, 2*PI*0.98, 2*PI*0.02));
  //blocks.add(makeSphericalMirror(3*width/4 + -1*width/45, height/2, width/2, 500, 2*PI*0.48, 2*PI*0.52));
  
  //blocks.add(makeSphericalMirror(width/2, height/4 + width/45, height/2, 500, 2*PI*0.23, 2*PI*0.27));
  
  
  for(int i = 0; i < 0; i ++) {
    Emitter emitter = new Emitter(new PVector(0.5*width, 1.2*height), blocks);
    emitters.add(emitter);
    //emitter.addAttractor(new PVector(width/2, height/2));
    emitter.velocity.y = -1.2*height;
  }
  
  randomSeed(seed);
  emitter0 = new Emitter(new PVector(random(0.2,0.8)*width, 1.2*height), blocks);
  emitter0.velocity.y = -random(1.5,1.9)*height;
  emitter0.velocity.x = random(-0.3, 0.3)*height;
  fireworkNo++;
  
}

/*---------------------------------------------------------------
Draw
----------------------------------------------------------------*/

void draw() {
  //explode a firework
  if (emitter0.intensity > 0 && abs(emitter0.velocity.y) < 0.02*height) {
    PVector pos = emitter0.position.copy();
    emitter0.intensity = -1;
    colorMode(HSB);
    float c = random(0,255);
    color col = color(c, 255, 255);
    explode(pos, col);
    col = color( (c+random(108, 148)) % 255, 255, 255);
    explode(pos, col);
    //explodeCentre(pos);
    colorMode(RGB);
  } else if(emitter0.intensity > 0) {
    emitter0.update();
  } else { //reset
    if(fireworkNo % nFireworks == 0) {
      print("reset ");
      randomSeed(seed);
    }
    emitter0 = new Emitter(new PVector(random(0.2,0.8)*width, 1.2*height), blocks);
    emitter0.velocity.y = -random(1.5,1.9)*height;
    emitter0.velocity.x = random(-0.3, 0.3)*height;
    fireworkNo++;
  }
  
  //update
  for (Emitter emitter : emitters) {
    emitter.update();
    emitter.intensity = 0.95*emitter.intensity;
  }
  
  //remove dead
  for(int i = emitters.size()-1; i > 0; i --) {
    if(emitters.get(i).intensity <= 0.95) {
      emitters.remove(i);
    }
  }
    
  for(int n = 0; n < 1; n++) {
    background(0);
    blendMode(ADD);
    
    
    for(int i = 0; i < blocks.size(); i++) {
      Block b = blocks.get(i);
      //b.setPosition(width/16 * sin (0.5 * frameCount * revs ), 0);
      //b.display();
    }
    //blocks.get(0).setPosition(width/120 * sin (0.5 * frameCount * revs ), 0);
    //blocks.get(0).setRotation(0.2*frameCount*revs, width/4, height/2);
    
    if(emitter0.intensity > 0) {
      emitter0.reset();
      emitter0.emitRadial(300,0);
      emitter0.trace();
      emitter0.displayRays();
    }
    
    for (Emitter emitter : emitters) {
      //emitter.blocks = blocks;
      emitter.reset();
      emitter.emitRadial(300,0);
      //emitter.emitLaser(30,80,PI, 30);
      emitter.trace();
      emitter.displayRays();
      emitter.displayTrails(emitter.intensity*10, 1.0, 0);
    }
    
    //addMist(4, 3.0, 0.05);
    if(frameCount <= T*fps) {
      //saveFrame("frame-###_" + n + ".png");
    }
    
    if(fireworkNo > nFireworks && fireworkNo <= 2*nFireworks) {
      saveFrame("frame-###_" + n + ".png");
    }
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