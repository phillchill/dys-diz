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
  
  /// State ///
  Boolean isScanning = false;
  // DEBUG: useful to disable video during development to start sketch faster
  Boolean isCapturingVideo = false; 
  
  /// UI ///
  ControlP5 cp5;
  // colors
  color green = #74ab3f;
  color yellow = #ffee61;
  color blue = #049ad5;
  color red = #ce5d2c;
  color black = #000000;
  
  PImage scanShape;
  float scanShapeScale = 1;
  
  PImage title = loadImage("images/ui/DD_title_hladacik.png");
  
  PImage scanDefault = loadImage("images/ui/DD_H1-100x100.png");
  PImage scanLight   = loadImage("images/ui/DD_H1-100x100-light.png");

  PImage backDefault = loadImage("images/ui/DD_icon2-40px.png");
  PImage backLight   = loadImage("images/ui/DD_icon2-40px-light.png");
  
  // UI sizes
  int backSize = 40;
  int scanSize = 80;
  
  int titleHeight = 20;
  float titlePadding = 20;
  float headerHeight = titleHeight + 2 * titlePadding;

  LetterScanner(PApplet sketch, int scanWidth, int scanHeight, String classifierPath, String scanShapePath) {
    this.sketch     = sketch;
    this.scanWidth  = scanWidth;
    this.scanHeight = scanHeight;
    this.scanShape  = loadImage(scanShapePath);
    
    this.opencv     = new OpenCV(this.sketch, this.scanWidth/this.scaleDownFactor, this.scanHeight/this.scaleDownFactor);
    this.opencv.loadCascade(classifierPath, true);
    
    /// GUI ///
    
    // Scan button
    scanDefault.resize(this.scanSize,this.scanSize);
    scanLight.resize(this.scanSize,scanSize);
    PImage[] scanButtonStates = {
      scanDefault, // default
      scanLight,   // over
      scanDefault, // active
    };
    
    // Back button
    backDefault.resize(this.backSize,this.backSize);
    backLight.resize(this.backSize,backSize);
    PImage[] backButtonStates = {
      backDefault, // default
      backLight,   // over
      backDefault, // active
    };
    
    // header
    this.title.resize(0 , this.titleHeight);
    
    this.cp5 = new ControlP5(this.sketch);
    
    this.cp5.addButton("scanbutton")
      .setValue(128)
      .setImages(scanButtonStates)
      .updateSize()
      .setPosition((width/(2*this.scaleDownFactor))- (0.5 * this.cp5.getController("scanbutton").getWidth()), height-150)
      .bringToFront()
      .addCallback(new CallbackListener() {
        void controlEvent(CallbackEvent theEvent) {
          if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
            toggleScanning();
          }
        }
      })
      ;
    
    this.cp5.addButton("backbutton")
      .setValue(128)
      .setImages(backButtonStates)
      .updateSize()
      .setPosition(20, 10)
      .bringToFront()
      .addCallback(new CallbackListener() {
        void controlEvent(CallbackEvent theEvent) {
          if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
            back();
          }
        }
      })
      ;
    
    
    
    if (this.isCapturingVideo) {
      startVideo();
    }
  }
  
  void startVideo() {
    this.video = new Capture(this.sketch, this.scanWidth/this.scaleDownFactor, this.scanHeight/this.scaleDownFactor);
    this.video.start();
  }
  
  // call run() in draw function of parent sketch
  void run() {
    scale(this.scaleDownFactor);
    
    if (this.isCapturingVideo) {
      
      this.display();
      
      if (this.isScanning) {
      
        this.scan();
      }
    }
        
    this.drawGUI();
  }
  
  
  
  void display() {
    image(video, 0, 0 );
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
  
  void back() {
    println("back to main app / library");
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
    // header
    fill(green);
    noStroke();
    rect(0,0, width, this.headerHeight);
    imageMode(CENTER);
    image(this.title, 
          width/(2*this.scaleDownFactor), 
          this.title.height / 2 + this.titlePadding
    );
    imageMode(CORNER);
  }
}

// read when new video frame is available
void captureEvent(Capture c) {
  c.read();
}