////////
// The following code will simulate the simple addition of sine waves
// The waves are modeled as circular waves radiating from a single point 
// If the wave desired is linear just set the center of the wave very far away
// Adding a floor will allow you to chose differnt gradients to shift the center gravity
// You can also creat your own gradients and explore how the mass behaves
// any questions let me know: sebmoralesprado@gmail.com
// July 2015
////////

import peasy.*;
PeasyCam cam;
import controlP5.*;    // import controlP5 library
import processing.opengl.*;
PImage gradient;

ControlP5 controlP5;   // controlP5 object
boolean writing=false,writingFloor=false;
boolean floorPresent=false;

float scale=.5;
int canvasWidth=int(1300*scale);
int canvasHeight=int(350*scale);
int sparcityPoints=5; //How close together are the verticies, lower sparcities (1) will give better surfaces but are slower and harder to work with
int cols, rows;
ArrayList<PVector> points=new ArrayList();

//WAVES:
float amp1, amp2, amp3, amp4, amp5,amp6;
float frq1, frq2, frq3, frq4, frq5,frq6;
int direction1, direction2, direction3, direction4, direction5,direction6; 
int distance1, distance2, distance3, distance4, distance5,distance6;
boolean Wave1, Wave2, Wave3, Wave4, Wave5,Wave6;
int age1,age2,age3,age4,age5,age6; //age refers to how many cycles will the wave live before stopping
float z, z1, z2, z3, z4, z5,z6, zNeg;
float zMax=0;
float zMin=0;
float radians=0.0174532925;

PrintWriter write;
PrintWriter writeFloor;

//Centroid Calculation
float[] zRowSum= new float[canvasHeight/sparcityPoints];
float[] zRowMult= new float[canvasHeight/sparcityPoints];
float Floor=0;
boolean floor,centroids;

//Menus
int topMenu=40;
int sideMenu=120;
int minThickness=10;
int thicknessMultiplier=20;



void setup() {
  size(1440, 850, OPENGL);
  
  age1=age2=age3=age4=age5=age6=1000;
  controlP5 = new ControlP5(this);
  controlP5.addKnob("direction1", 0, 360, 0, sideMenu-80, topMenu, 70);
  controlP5.addToggle("Wave1", false, sideMenu, topMenu, 25, 10);
  controlP5.addSlider("distance1", 400, 2000, 0, sideMenu, topMenu+30, 100, 10);
  controlP5.addSlider("amp1", 0, 50, 0, sideMenu, topMenu+50, 100, 10);
  controlP5.addSlider("frq1", 0, 5, 0, sideMenu, topMenu+70, 100, 10);

  controlP5.addKnob("direction2", 0, 360, 0, sideMenu-80, topMenu+100, 70);
  controlP5.addToggle("Wave2", false, sideMenu, topMenu+100, 25, 10);
  controlP5.addSlider("distance2", 0, 2000, 0, sideMenu, topMenu+130, 100, 10);
  controlP5.addSlider("amp2", 0, 50, 0, sideMenu, topMenu+150, 100, 10);
  controlP5.addSlider("frq2", 0, 6, 0, sideMenu, topMenu+170, 100, 10);


  controlP5.addKnob("direction3", 0, 360, 0, sideMenu-80, topMenu+200, 70);
  controlP5.addToggle("Wave3", false, sideMenu, topMenu+200, 25, 10);
  controlP5.addSlider("distance3", 200, 2000, 0, sideMenu, topMenu+230, 100, 10);
  controlP5.addSlider("amp3", 0, 30, 0, sideMenu, topMenu+250, 100, 10);
  controlP5.addSlider("frq3", 0, 15, 0, sideMenu, topMenu+270, 100, 10);


  controlP5.addKnob("direction4", 0, 360, 0, sideMenu-80, topMenu+300, 70);
  controlP5.addToggle("Wave4", false, sideMenu, topMenu+300, 25, 10);
  controlP5.addSlider("distance4", 0, 2000, 0, sideMenu, topMenu+330, 100, 10);
  controlP5.addSlider("amp4", 0, 15, 0, sideMenu, topMenu+350, 100, 10);
  controlP5.addSlider("frq4", 0, 20, 0, sideMenu, topMenu+370, 100, 10); 
  //controlP5.addSlider("age4", 0, 50, 0, sideMenu, topMenu+560, 100, 10);   


  controlP5.addKnob("direction5", 0, 360, 0, sideMenu-80, topMenu+400, 70);
  controlP5.addToggle("Wave5", false, sideMenu, topMenu+400, 25, 10);
  controlP5.addSlider("distance5", 0, 2000, 0, sideMenu, topMenu+430, 100, 10);
  controlP5.addSlider("amp5", 0, 10, 0, sideMenu, topMenu+450, 100, 10);
  controlP5.addSlider("frq5", 0, 20, 0, sideMenu, topMenu+470, 100, 10);  
  //controlP5.addSlider("age5", 0, 50, 0, sideMenu, topMenu+700, 100, 10);  

  controlP5.addKnob("direction6", 0, 360, 0, sideMenu-80, topMenu+500, 70);
  controlP5.addToggle("Wave6", false, sideMenu, topMenu+500, 25, 10);
  controlP5.addSlider("distance6", 0, 2000, 0, sideMenu, topMenu+530, 100, 10);
  controlP5.addSlider("amp6", 0, 40, 0, sideMenu, topMenu+550, 100, 10);
  controlP5.addSlider("frq6", 0, 20, 0, sideMenu, topMenu+570, 100, 10);  

  controlP5.addToggle("floor",false,sideMenu-80, topMenu+600, 20, 20);
  controlP5.addToggle("centroids",false,sideMenu-80+30, topMenu+600, 20, 20);  
  controlP5.addSlider("thicknessMultiplier", 1, 100, 0, sideMenu-80, topMenu+640, 100, 10);  
  controlP5.addSlider("minThickness", 0, 30, 10, sideMenu-80, topMenu+660, 100, 10);  
  controlP5.addBang("LoadGradient",sideMenu-80, topMenu+680, 20, 20);
  controlP5.addBang("save",sideMenu-80, topMenu+720, 20, 20);


  controlP5.setAutoDraw(false);
  cols = canvasWidth/sparcityPoints;
  rows = canvasHeight/sparcityPoints;
  cam = new PeasyCam(this,(canvasWidth/2)-100,canvasHeight/2,0, 1000);
  cam.setMinimumDistance(0);
  cam.setMaximumDistance(3000);
}

void draw() {
  background(0);
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      int x = j*sparcityPoints;
      int y = i*sparcityPoints;
      if (Wave1) {
        distToPoint(direction1, distance1, x, y, amp1, frq1,age1);
        z1=z;
      }
      if (Wave2) {
        distToPoint(direction2, distance2, x, y, amp2, frq2,age2);
        z2=z;
      }
      if (Wave3) {
        distToPoint(direction3, distance3, x, y, amp3, frq3,age3);
        z3=z;
      }
      if (Wave4) {
        distToPoint(direction4, distance4, x, y, amp4, frq4,age4);
        z4=z;
      }
      if (Wave5) {
        distToPoint(direction5, distance5, x, y, amp5, frq5,age5);
        z5=z;
      }
      if (Wave6) {
        distToPoint(direction6, distance6, x, y, amp6, frq6,age6);
        z6=z;
      }
      z=z1+z2+z3+z4+z5+z6;      
      
      //Calculating Wave Thickness
      if(z<zMin){zMin=int(z);}
      if(z>zMax){zMax=int(z);}
      
      //Calculating Floor using gray scale gradient
      if(floor && gradient!=null){
        getFloor(x,y); 
        fill(255);
        stroke(50,100,120);
        findingFloor(x,y,z);//will return zNeg wich is the value of Z for the Floor
        point(x,y,zNeg);
   
        //Calculating Centroids by Row
        if (j==0){zRowSum[i]=0;zRowMult[i]=0;} 
          zRowSum[i]+=(z-zNeg);
          zRowMult[i]=zRowMult[i]+j*(z-zNeg);
      }
      
      if(floor && !floorPresent){
        selectInput("Select a gradient:", "fileSelected");
        floorPresent=true;
      }
       
      //saving Floor points to file
      if (writingFloor) {
         writeFloor.println(x+" "+y+" "+zNeg);
         if (i==rows-1) {
           writingFloor=false;
           writeFloor.flush();
           writeFloor.close();
           println("finished writing Floor to file");
         }
       }
     
      //Printing Wave Points
      stroke(255);
      point(x, y, z);    
      if (writing) {
        write.println(x+" "+y+" "+z);
        if (i==rows-1) {
          writing=false;
          write.flush();
          write.close();
          println("finished writing to file");
        }
      }
    }
  // Printing Rows centroid
 if (centroids){
  stroke(51,255,0); 
  point(zRowMult[i]/zRowSum[i]*2,i*2, zRowSum[i]/(canvasWidth/sparcityPoints));
  // Draw center line
  stroke(255,10,10);
  line(canvasWidth/2,0,0,canvasWidth/2,canvasHeight,0);
  stroke(10,10,255);
  line(canvasWidth/3,0,0,canvasWidth/3,canvasHeight,0);
 }
  }
  gui();
  zMin=0;
  zMax=0;
}

void distToPoint(int dir, int dis, int x1, int y1, float amp, float frq,int age) {
  float y0=dis*sin(dir*radians);
  float x0=dis*cos(dir*radians);
  float distPoint=sqrt(sq(x1-x0)+sq(y1-y0));
  z=amp*sin((6.283*frq/canvasWidth)*distPoint);
  if(distPoint>=((canvasWidth/frq)*age)){
    z=0;
  }
}

void findingFloor(int xPixel,int yPixel,float zFloor){
  getFloor(xPixel,yPixel);// Floor will be  a value from 0-255
  zNeg=z-(Floor/255 *thicknessMultiplier+minThickness);
}


void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  controlP5.draw();
  //textSize(10);
  text("Max Z diff: "+ (zMax-zMin)*scale,sideMenu-80+30,topMenu+738);
  text("Sebastian Morales | adorevolution.com | Julio 2015",width-200, height-20);
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void save(){
    writing=true;
    writingFloor=true;
    write= createWriter("Points.txt");
    writeFloor= createWriter("PointsFloor.txt");
    saveFrame("Waves.png");
  }
  
void getFloor(int xPixel,int yPixel){
      int c=gradient.pixels[xPixel+yPixel*canvasWidth];
      int r=(c&0x00FF0000)>>16; // red part
      int g=(c&0x0000FF00)>>8; // green part
      int b=(c&0x000000FF); // blue part
      Floor=(r+b+g)/-3+255; 
}

void LoadGradient(){
  selectInput("Select a gradient:", "fileSelected");
}
void fileSelected(File selection) {
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    }
    else {
      println("User selected " + selection.getAbsolutePath());
      gradient=loadImage(selection.getAbsolutePath());
      loadPixels();
     // floor=true;
      floorPresent=true;
    }
}

