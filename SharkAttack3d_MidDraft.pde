
//==========================================================
// SharkAttack3d.pde
//   A flocking simulation with many fishes abd some sharks.
// based on flocking by Danial Shiffman   
//   http://processing.org/examples/flocking.html
// Originally by Thomas Koberger, 
//   http://lernprocessing.wordpress.com/2012/10/04/the-hunt/
// 3D fishes are taken from http://www.turbosquid.com/ 
// improvements 2013-12-08 by Gerd Platl
//   tested with processing v2.1
//   In JavaScript mode sketch crashes at loading 3d shapes?!?  
// tags: fishes, sharks, flock, shoal, simulate, simulation, 3d
//==========================================================

String title = ">>> SharkAttack3d v1.0 <<<";

Tree tree;
//PeasyCam cam;

float min_dist = 25;
float max_dist = 100;

// global settings
int fishCount = 15;
int sharkCount = 3;
int helpMode = 1;               // current help mode
boolean isPaused = false;
boolean saveMovie = false;
boolean showCube = false;
int movieFrameCount = 0;

// camera & background
PImage bgImage;
float rotx = 0.0;   // vertical rotation
float roty = 0.0;   // horizontal rotation

// shapes
String[] fishObjects = { "TropicalFish01.obj"
                       , "TropicalFish10.obj"
                       , "TropicalFish12.obj" };
                       
int fishObjectCount = fishObjects.length;
int fishObjIndex = 0;
PShape sharkShape, flockFish; 

// fishes & sharks
Flock flock;
ArrayList <Hunter> sharks;
int x=790;
//----------------------------------------------
void setup()
{
  //orientation (LANDSCAPE);   // Android
  //size(displayWidth, displayHeight, P3D);  // Android
  //size(480, 320);            // Android 
  size(800, 800, P3D);         // Android
  frameRate(30);
  tree = new Tree();
  println (title);
  smooth(8);
  bgImage = loadImage("underWater.png");
  image(bgImage, 0,0, width, height);
  bgImage = get();             // resize image to window size

  println ("loading objects...");
  sharkShape = loadShape("shark.obj");  
  sharkShape.scale(0.02, 0.02, 0.02);
  sharkShape.rotateX(PI/2);

  flockFish = loadFishShape (1, 0.1);

  createScene();
}
//----------------------------------------------
void draw() 
{
  //println ("draw: "+frameCount);
  background(bgImage);

  // lights
  ambientLight(0, 0, 20);
  directionalLight(80, 80, 120, 0, -1, 0);
  spotLight(200, 190, 200, 0, 0, 1400, 0, 0, -1, PI/4, 100);
  spotLight(180, 190, 180, 1500, 0, 1499, -1, 0, -1, PI/4, 100);
  lightSpecular(204, 220, 240); 
  lightFalloff(0.5, 0.5, 0.5);
  shininess(25.0);

  pushMatrix();
  translate (width/2, height/2);
  rotateX (rotx); 
  rotateY (roty); 

  if (mousePressed)
  {
    RotateHorizontal((mouseX-pmouseX)*0.005);
    RotateVertical((mouseY-pmouseY)*0.002);
    //println("rx="+nf(rotx,0,2));
  }

  noFill();
  stroke(55,55,122, 128);
  if (showCube) box (600, 400, 600);
  if (!isPaused)
    flock.animate (sharks);
  flock.render();
    
  // animate and draw all sharks
  for (Hunter shark : sharks) 
  {
    if (!isPaused)
      shark.animate (flock.fishes, sharks);
    shark.render();
  }
  popMatrix();

  if (saveMovie)
  {
    movieFrameCount++;
    saveFrame("data/SharkAttack3d-"+nf(movieFrameCount,4)+".png");
  }

  hint(DISABLE_DEPTH_TEST);
  noLights();
  drawHelpInformation();
  hint(ENABLE_DEPTH_TEST);
  


 
bubbles();
  
  scale(0.4);
  tree.show();
  tree.grow();
  
    
  //Coral Type
   //scale(0.3);
  tree.show2();
  tree.grow();


}
//----------------------------------------------
// create all fishes and sharks
//----------------------------------------------
void createScene()
{
  println ("creating scenery...");
  rotx = 0.0;   // vertical rotation
  roty = 0.0;   // horizontal rotation
  
  flock = new Flock();     // create fish flock
  // add an initial set of fishes to the flock
  flock.addFishes(fishCount);

  sharks = new ArrayList();     // create sharks
  // add an initial set of sharks to the scenery
  for (int i = 0; i < sharkCount; i++) 
    sharks.add(new Hunter(new PVector(width*random(0, 0.5), height*random(0, 0.5), height*random(-0.2, 0.2))
               , 5.0, 1.0));
}
//----------------------------------------------
// load fish shape from model file
//----------------------------------------------
PShape loadFishShape (int index, float scale)
{
  fishObjIndex = (index + fishObjectCount) % fishObjectCount;
  String fishName = fishObjects[fishObjIndex]; 
  println ("loadFishShape: " + (fishObjIndex+1) + "  " + fishName);
  PShape shape;
  try
  {
    shape = loadShape(fishName);
    shape.scale(scale, scale, scale);
    shape.rotateX(PI/2);
  }
  finally { }
  return shape;
}
//----------------------------------------------
void loadNextFish()
{
  flockFish = loadFishShape (fishObjIndex+1, 0.1);
}

//----------------------------------------------
// draw help depending on helpMode
//----------------------------------------------
void drawHelpInformation()
{ 
  if (frameCount < 200)
  {
    fill(255,255,122, constrain(400 - frameCount*3, 0,255));
    text ("press F1 to change help information", 140,20);
  }
  fill(255);
  
  if (helpMode >= 1) 
  {
    text (sharks.size() + " sharks", 25,22,0);
    text (flock.fishes.size() + " fishes",width/2,22,0);
    text (round(frameRate) + " fps",width-55,22,0);
  }

  if (helpMode == 2) 
  {
    text (" left mouse button   turn eye around"
      + "\n cursor left/right   turn eye left/right"
      + "\n page up/down        rotate up/down"
      + "\n +/-  add/remove fishes"
      + "\n F1,i  info on/off"
      + "\n F2,p  pause on/off"
      + "\n F3,c  cube on/off"
      + "\n F4,n  select next kind of fish" 
      + "\n F5/F6 add/remove fishes"
      + "\n F7/F8 add/remove sharks"
      + "\n F9,r  reset scene"
      + "\n F10,s  save scene as 'sharkAttack3d.png'"
      + "\n m   save movie on/off ('SharkAttack3d-####.png')"
    ,10,50);
  }
}
//----------------------------------------------
void changeHelp()                          
{
  helpMode = (helpMode+1) % 3;
}
//----------------------------------------------
void changeSharks (int delta)
{ 
  int count = constrain (sharks.size() + delta, 0, 100);
  if (delta < 0)
  { // remove sharks
    while (sharks.size() > count)
      sharks.remove(0);
  }
  else while (sharks.size() < count)
  { // add a shark at deep depending at mouse position
    sharks.add(new Hunter(new PVector(1.05*(mouseX-width/2), 0, -60+0.8*(height/2-mouseY)), 6.0, 0.02));
  }
} 
//----------------------------------------------
void RotateHorizontal(float deltaAngle)
{
  roty = (roty + deltaAngle + 2*PI) % (2*PI);
}
//----------------------------------------------
void RotateVertical(float deltaAngle)
{
  rotx = constrain (rotx + deltaAngle, -0.5, 0.5);
  //println ("rotx="+rotx);
}
void savePicture()
{
  String filename = "sharkAttack3d.png";
  save (filename);
  println ("picture '" +filename +"' saved"); 
}
//----------------------------------------------
void keyPressed()
{
  if (key == CODED)
  switch (keyCode)
  {        case   112: changeHelp();              // F1 
    break; case   113: isPaused = !isPaused;      // F2
    break; case   114: showCube = !showCube;      // F3
    break; case   115: loadNextFish();            // F4
    break; case   116: flock.addFishes(10);       // F5
    break; case   117: flock.remove(5);           // F6
    break; case   118: changeSharks(+1);          // F7
    break; case   119: changeSharks(-1);          // F8
    break; case   120: createScene();             // F9
    break; case   121: savePicture();             // F10
    break; case    33: RotateVertical(-0.01);     // page up
    break; case    34: RotateVertical(+0.01);     // page down
    break; case  LEFT: RotateHorizontal(+0.05);   // rotation to left
    break; case RIGHT: RotateHorizontal(-0.05);   // rotation to right
  }
  else switch (key)
  {        case   '+': flock.addFishes(10);
    break; case   '-': flock.remove(5);
    break; case   'd': changeSharks(-1);
    break; case   'a': changeSharks(+1);
    break; case   'c': showCube = !showCube;
    break; case   'i': changeHelp();;
    break; case   'm': saveMovie = !saveMovie;
    break; case   'n': loadNextFish(); 
    break; case   'p': isPaused = !isPaused;
    break; case   'r': createScene();
    break; case   's': savePicture(); 
  }
}
//----------------------------------------------
void mousePressed() 
{
  if ( mouseButton == RIGHT) 
    changeSharks (+1);
}



void bubbles(){

    for(int b=1;b<=40;b++){
  
   float y = random(0,800); 
    
  ellipse(y, x, 4, 4);
 
    x--;
  }
    if(x<=5)
      x=790;
     

}