// Based on original code by Daniel Shiffman
// http://codingtra.in  // http://patreon.com/codingtrain
// Code for: https://youtu.be/QLHMtE5XsMs

// Modified by Sam.T.Rees 29/06/21 
// for JRC Makerspace EU Pollinators Recording 

import processing.video.*;

Capture video;
PImage prev;

float threshold = 25;

float motionX = 0;
float motionY = 0;

float lerpX = 0;
float lerpXstored = 0;
float lerpY = 0;
int camCount = 0;

void setup() {
  size(960, 540);
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, cameras[31]);
  video.start();
  prev = createImage(960, 540, RGB);
  // Start off tracking for red
}


void mousePressed() {
  saveFrame(); 
}

void captureEvent(Capture video) {
  prev.copy(video, 0, 0, video.width, video.height, 0, 0, prev.width, prev.height);
  prev.updatePixels();
  video.read();
}

void draw() {
  video.loadPixels();
  prev.loadPixels();
  image(video, 0, 0);

  //threshold = map(mouseX, 0, width, 0, 100);
  threshold = 50;


  int count = 0;
  
  
  float avgX = 0;
  float avgY = 0;

  loadPixels();
  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      color prevColor = prev.pixels[loc];
      float r2 = red(prevColor);
      float g2 = green(prevColor);
      float b2 = blue(prevColor);

      float d = distSq(r1, g1, b1, r2, g2, b2); 

      if (d > threshold*threshold) {
        //stroke(255);
        //strokeWeight(1);
        //point(x, y);
        avgX += x;
        avgY += y;
        count++;
        pixels[loc] = color(255);
      } else {
        pixels[loc] = color(0);
      }
    }
  }
  updatePixels();

  // We only consider the color found if its color distance is less than 10. 
  // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
  if (count > 200) { 
    motionX = avgX / count;
    motionY = avgY / count;
    // Draw a circle at the tracked pixel
  }
  
  lerpX = lerp(lerpX, motionX, 0.1); 
  lerpY = lerp(lerpY, motionY, 0.1); 

  // Show the live stream image
  image(video, 0, 0, 960, 540);
  
  fill(255, 0, 255);
  strokeWeight(2.0);
  stroke(0);
  
  // set size to zero for ellipse to be invisible or larger for troubleshooting cause of motion
  ellipse(lerpX, lerpY, 1, 1);
  
  // my addition - trying to trigger a frame grab when greater than certain amount of motion
  if (abs(lerpXstored-lerpX) > 15) { 
    println("TRIGGER HAPPY ");
    println("lerpX =", lerpX);
    println("lerpXstored =", lerpXstored); 
    println("camCount =", camCount);
    
    // How often do you want it to snap photos? e.g. % 10 is every ten frames... % 20 every 20, etc
    if (camCount % 2 == 0) { 
      println("camCount divisible by ten! =", camCount);
      saveFrame();
    }
    
    camCount = camCount+1;
  }
  
  lerpXstored = lerpX;

  //image(prev, 100, 0, 100, 100);

  //println(mouseX, threshold);
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
