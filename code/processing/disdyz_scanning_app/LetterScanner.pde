import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import controlP5.*;
import java.util.Map;

class LetterScanner 
{
  Capture video;
  OpenCV opencv;
  PApplet sketch;
  int scanWidth, scanHeight;
  int scaleDownFactor = 1; // increase to increase performance, but loses detection accuracy
  Rectangle[] faces;
  
  // State
  Boolean isScanning = false;
  
  // UI
  PImage scanShape;
  float scanShapeScale = 1;
  ControlP5 cp5;
  PImage[] scanButtonStates = {
    loadImage("images/buttons/button_a.png"), // default
    loadImage("images/buttons/button_b.png"), // over
    loadImage("images/buttons/button_c.png"), // active
  };
  PImage title = loadImage("images/ui/DD_HLADACIK.png");
  // colors
  color green = #74ab3f;
  color yellow = #ffee61;
  color blue = #049ad5;
  color red = #ce5d2c;
  color black = #000000;

  LetterScanner(PApplet sketch, int scanWidth, int scanHeight, String classifierPath, String scanShapePath) {
    this.sketch     = sketch;
    this.scanWidth  = scanWidth;
    this.scanHeight = scanHeight;
    this.scanShape  = loadImage(scanShapePath);
    
    this.opencv     = new OpenCV(this.sketch, this.scanWidth/this.scaleDownFactor, this.scanHeight/this.scaleDownFactor);
    this.opencv.loadCascade(classifierPath, true);
    
    // GUI
    this.cp5 = new ControlP5(this.sketch);
    this.cp5.addButton("scanbutton")
      .setValue(128)
      .setImages(scanButtonStates)
      .updateSize()
      .setPosition((width/(2*this.scaleDownFactor))- (0.5 * this.cp5.getController("scanbutton").getWidth()), height-100)
      .bringToFront()
      .addCallback(new CallbackListener() {
        void controlEvent(CallbackEvent theEvent) {
          if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
            toggleScanning();
          }
        }
      })
      ;
    
    startVideo();
  }
  
  void startVideo() {
    this.video = new Capture(this.sketch, this.scanWidth/this.scaleDownFactor, this.scanHeight/this.scaleDownFactor);
    this.video.start();
  }
  
  // call run() in draw function of parent sketch
  void run() {
    scale(this.scaleDownFactor);
    
    this.display();
    
    if (this.isScanning) {
      this.scan();
    }
  }
  
  void display() {
    image(video, 0, 0 );
    this.drawGUI();
  }
  
  void scan() {
    this.opencv.loadImage(video);
    this.faces = opencv.detect();
    //println(this.faces.length);
    this.drawScanShape();
    this.drawDetected();
  }
  
  void toggleScanning() {
    println("Toggle Scanning");
    this.isScanning = ! this.isScanning;
  }
  
  void drawScanShape() {
    imageMode(CENTER);
    image(this.scanShape, this.scanShapeScale * width/(2*this.scaleDownFactor), this.scanShapeScale * height/(2*this.scaleDownFactor), this.scanShape.width/(2*this.scaleDownFactor), this.scanShape.height/(2*this.scaleDownFactor) );
    imageMode(CORNER);
  }
  
  void drawDetected() {
    // draw rects around detected objects
    noFill();
    stroke(255, 255, 255, 100);
    //stroke(0, 255, 0);
    strokeWeight(1);  
    for (int i = 0; i < this.faces.length; i++) {
      println(this.faces[i].x + "," + this.faces[i].y);
      rect(this.faces[i].x, this.faces[i].y, this.faces[i].width, this.faces[i].height);
    }
  }
  
  void drawGUI() {
    fill(green);
    noStroke();
    //rect(0,0, title.width * (width / title.width), title.height * (width / title.width));
    image(title, 0, 0, title.width * (1.0 * width / title.width), title.height * (1.0 * width / title.width));
  }
}

// read when new video frame is available
void captureEvent(Capture c) {
  c.read();
}