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
-hack up a diffuse reflection effect
-post-processing style effects
----------------------------------------------------------------*/
import java.awt.Color;

int fps = 30;
float revs = TWO_PI/fps;
ArrayList<Block> blocks;
ArrayList<Emitter> emitters;
int T = 10;
/*---------------------------------------------------------------
Setup
----------------------------------------------------------------*/

void setup(){
  //P3D renderer looked best in tests
  size(700,700, P3D);
  frameRate(fps);
  //use blendMode ADD for physical combination of ray colours
  //blendMode(ADD);
  
  blocks = new ArrayList<Block>();
  emitters = new ArrayList<Emitter>();
  
  //make the blocks
  float theta;
  for(int i = 0; i < 5; i++) {
    theta = i * TWO_PI/5;
    //blocks.add(makeDisk(width/2 + width/4 * cos(theta), height/2 + height/4 * sin(theta),
    //    width/20, 12));
  }
  
  for(int i = 0; i < 20; i ++) {
    Emitter emitter = new Emitter(new PVector(width/2, 0.5*height), blocks);
    emitter.velocity.y = 0; //height*0.2;
    emitters.add(emitter);
  }
}

/*---------------------------------------------------------------
Draw
----------------------------------------------------------------*/

void draw() {
  background(0);
  blendMode(ADD);
  
  for(Block b : blocks) {
    //b.display();
  }
  
  //lights set 1
  for(int i = 0; i < emitters.size(); i++) {
    Emitter emitter = emitters.get(i);
    emitter.reset();
    float theta = i*TWO_PI/emitters.size();
    float thetaFactor = 0;
    
    //smooth step type function
    float cFactor = floor(frameCount/float(2*fps)) + 0.2*fps*(frameCount/float(2*fps) - floor(frameCount/float(2*fps)));
    
    //asd enveloped sin waves for angle dependence 
    for(int n = 0; n < T; n += 2) {
      thetaFactor += envelope(0.02,0.06,0.02,frameCount+n*fps,T*fps);
      //cFactor += floor(frameCount/float(n*fps)) + 0.2*fps*(frameCount/float(n*fps) - floor(frameCount/float(n*fps)));
    }
    thetaFactor *= map(cos(2*revs*frameCount - 5*theta), -1, 1, 0, 1);
    
    float r = width/4 +thetaFactor*width/20;//* sin(revs*frameCount);
    
    emitter.position = new PVector(width/2 + r*cos(theta+ 0.1*revs*frameCount), height/2 + r *sin(theta + 0.1*revs*frameCount));
    //emitter.update();
    emitter.emitRadial(1300 + int(thetaFactor*3000), 1);
    emitter.trace();
    color c = Color.HSBtoRGB(float(i)/emitters.size()*1.0 +0.2*cFactor, 1.0, 1.0);
    emitter.displayRays(c);
  }

  //lights set 2
  for(int i = 0; i < emitters.size(); i++) {
    Emitter emitter = emitters.get(i);
    emitter.reset();
    float theta = -1*i*TWO_PI/emitters.size();
    float thetaFactor = 0;
    for(int n = 0; n < T; n += 2) {
      thetaFactor += envelope(0.02,0.06,0.02,frameCount+n*fps,T*fps);
    }
    thetaFactor *= map(cos(2*revs*frameCount - 5*theta), -1, 1, 0, 1);
    
    float r = width/4 +thetaFactor*width/20;//* sin(revs*frameCount);
    
    emitter.position = new PVector(width/2 + r*cos(theta+ 0.1*revs*frameCount), height/2 + r *sin(theta + 0.1*revs*frameCount));
    //emitter.update();
    emitter.emitRadial(1300 + int(thetaFactor*3000), 1);
    emitter.trace();
    color c = Color.HSBtoRGB(float(i)/emitters.size()*1.0, 1.0, 1.0);
    emitter.displayRays(c);
  }
  
  
  //addMist(4, 3.0);
  if(frameCount <= T*fps) {
    saveFrame("frame-###.png");
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

void addMist(float r, float T) {
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
      mistLevel *= 0.2*255 * (1-brightness(pixels[y*width + x])/255.0);//(1-pow(brightness(pixels[y*width + x])/255.0, 2.1));
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