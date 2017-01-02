// To get the sound 
import processing.sound.*;
SawOsc saw;
SqrOsc sqr;
//for sawtooth wave
BandPass bandPass;
//for square wave
LowPass lowPass;

//To get camera frame input
import processing.video.*; 
Capture cam; 
PImage camSnapshot;

//To detect when is the mouse pressed.
int claim = 1;

//Parameters for audio generation. 
float amplitude, frequency;
float curAmp = 0, ampStart = 0, ampDest = 0; 
float curBandwidth = 0, cutoff = 100;
int startFrame = -1, endFrame = -1;


void setup(){
// Intialisation of the background (blue color) 
  size(400,500);
  colorMode(RGB);
//reduce the FRAME RATE to avoid crashing.
  frameRate(30);
  
  camSnapshot = createImage(80,100,RGB);
  background(64,191,191);
  noFill();
  smooth();

  
//To initialise camera input
  cam = new Capture(this,80,100,30);
  cam.start();
  
//Introducing a Band Pass Filter (saw) and Low Pass Filter(sqr)
  bandPass = new BandPass(this);
  lowPass = new LowPass(this);

//Using a saw tooth Oscillator.
  saw = new SawOsc(this);
  saw.play();
  saw.amp(0.);
  bandPass.process(saw, 200,50);      // set initial parameters - frequency and bandwidth ?

//Using square wave oscillator
  sqr = new SqrOsc(this);
  sqr.play();
  sqr.amp(0.);   //set initial amplitude as zero.
  lowPass.process(sqr, 500);      // set initial parameters - cut off frequency 

}
 
void draw(){
 // Aesthetics (Name of the project)
  colorMode(RGB);
  textSize(45);
  text("UR",0,45); 
  fill(0,0,0);
  textSize(45);
  text("tune",60,45);  
  fill(255,255,255);
  colorMode(HSB);
// To increase the thickness of the drawing 
  strokeWeight(4);
  
 
  if(frameCount < endFrame)
  updateAmplitude();
 
  if(claim == 0)
  {
    //Sketching the waveform
    beginShape();
    vertex(pmouseX,pmouseY);
    vertex(mouseX,mouseY);
    endShape();
    
   // Mapping frequency for square (called saw right now) to correct appropriate ranges
    frequency = 500-map(mouseY, 0, height, 200, 500);
    saw.freq(frequency+20);
    sqr.freq(frequency);
    
   //implementing filters on the waveforms
    float bright = getColumnBrightness(mouseX);
    curBandwidth = map(bright, 0, 255, 5, 100);
    cutoff = map(bright, 0, 255, 500, 5000);
    bandPass.bw(curBandwidth);
    lowPass.freq(cutoff);
    
    
  }

// to draw camera image on the output
if (cam.available()){
  cam.read();
}
 image (cam,320,400);
 if(claim == 0)
 {
   camSnapshot = cam; 
 }
 
 
  colorMode(RGB);
  strokeWeight(2);
  fill(64,191,191,5);
  rect(0,0,width-1,height-1);
}
 
 // When the mouse is pressed
 void mousePressed() {
   // start amplitude ramp up
   claim=0;
   amplitudeRamp(3.0, 0.6);
 }

 //When mouse is released
 void mouseReleased() {
   // start amplitude ramp down
   claim=1;
   amplitudeRamp(3.0, 0.0);
 }
//enables amplitude mapping (sets the new values of the data required to do the amplitude mapping )
 void amplitudeRamp( float seconds, float destVal )
 {
    startFrame = frameCount;
    endFrame = int(frameCount + seconds * 90);
    ampStart = curAmp;
    ampDest = destVal;
 }
 //enables amplitude mapping ( sets the current amplitde and feeds it to the sqr tooth wave)
 void updateAmplitude()
 {
    curAmp = map(frameCount, startFrame, endFrame, ampStart, ampDest);
    sqr.amp( curAmp );
 }

//averaging the brightness of the current snapshot
float getColumnBrightness(int column)
{
  float count = 0;
  camSnapshot.loadPixels();
  
 int camColumn = int(map(column, 0, width, 0, camSnapshot.width));

  for(int y=0; y<camSnapshot.height; y++)
  {
    int pos = camColumn + y * camSnapshot.width ;
    if ( pos>=0 && pos <8000)
{
    float val = brightness(camSnapshot.pixels[pos]);
    println("brightness"+val);
    count += val;
}
  }
  
  float total = count / camSnapshot.height;
  return total;
}