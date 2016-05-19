import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import controlP5.*;
import java.util.Map;

class LetterScanner 
{
  /// State ///
  Boolean isScanning = true;
  // DEBUG: useful to disable video during development to start sketch faster
  Boolean isCapturingVideo = true;
  
  Movie introMovie;
  Movie scanSuccessP;
  Movie scanMistakeP;
  
  Capture video;
  OpenCV opencv;
  PApplet sketch;
  
  Boolean isPhotoToBeCaptured = false;
  Capture photoCaptured;
  
  int scanWidth, scanHeight;
  int scaleDownFactor = 1; // increase to increase performance, but loses detection accuracy
  Rectangle[] faces;
  
  /// UI ///
  ControlP5 cp5;
  // colors
  color green = #74ab3f;
  color yellow = #ffee61;
  color blue = #049ad5;
  color red = #ce5d2c;
  color black = #000000;
  
  PImage scanShape;
  float scanShapeScale  = 0.5;
  
  PImage title          = loadImage("images/ui/DD_title_hladacik.png");
  PImage scanDefault    = loadImage("images/ui/DD_H1-100x100.png");
  PImage scanLight      = loadImage("images/ui/DD_H1-100x100-light.png");
  PImage backDefault    = loadImage("images/ui/DD_icon2-40px.png");
  PImage backLight      = loadImage("images/ui/DD_icon2-40px-light.png");
  
  // UI sizing & positioning
  int scanShapeHeight   = height / 2;
  int backButtonSize    = 40;
  int scanButtonSize    = 80;
  int scanButtonPadding = 30;
  int titleHeight       = 20;
  float titlePadding    = 20;
  float headerHeight    = titleHeight + 2 * titlePadding;
  
  // UI timing
  
  int photoAnimationDuration    = 1000;
  int photoAnimationTimer       = -1;
  int photoAnimationStartTime   = -1;
  Boolean photoAnimationRunning = false;
  Boolean hasMovieStarted       = false;

  LetterScanner(PApplet sketch, int scanWidth, int scanHeight, String classifierPath, String scanShapePath) {
    this.sketch     = sketch;
    this.scanWidth  = scanWidth;
    this.scanHeight = scanHeight;
    this.scanShape  = loadImage(scanShapePath);
    
    this.opencv     = new OpenCV(this.sketch, this.scanWidth/this.scaleDownFactor, this.scanHeight/this.scaleDownFactor);
    this.opencv.loadCascade(classifierPath, true);
    
    //// GUI ////
    
    // Videos
    introMovie      = new Movie(this.sketch, "video/test-1-3.mov");
    scanSuccessP    = new Movie(this.sketch, "video/test-1-3.mov");
    scanMistakeP    = new Movie(this.sketch, "video/test-1-3.mov");
    
    // resize UI image elements
    this.title.resize(0 , this.titleHeight);
    this.scanShape.resize(0, this.scanShapeHeight);
    
    /// Buttons ///
    
    this.cp5 = new ControlP5(this.sketch);
    
    // Scan button
    scanDefault.resize(this.scanButtonSize,this.scanButtonSize);
    scanLight.resize(this.scanButtonSize,scanButtonSize);
    PImage[] scanButtonStates = {
      scanDefault, // default
      scanLight,   // over
      scanDefault, // active
    };
    
    // Back button
    backDefault.resize(this.backButtonSize, this.backButtonSize);
    backLight.resize(this.backButtonSize, this.backButtonSize);
    PImage[] backButtonStates = {
      backDefault, // default
      backLight,   // over
      backDefault, // active
    };
    
    this.cp5.addButton("scanbutton")
      .setValue(128)
      .setImages(scanButtonStates)
      .updateSize()
      .setPosition((width/(2*this.scaleDownFactor))- (0.5 * this.cp5.getController("scanbutton").getWidth()), height-this.cp5.getController("scanbutton").getHeight()-this.scanButtonPadding)
      .bringToFront()
      .addCallback(new CallbackListener() {
        void controlEvent(CallbackEvent theEvent) {
          if (theEvent.getAction() == ControlP5.ACTION_BROADCAST) {
            //toggleScanning();
            takePhoto();
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
      startVideoCapture();
    }
  }
  
  void startVideoCapture() {
    this.video = new Capture(this.sketch, this.scanWidth/this.scaleDownFactor, this.scanHeight/this.scaleDownFactor);
    this.video.start();
  }
  
  void stopVideoCapture() {
    if (this.isCapturingVideo){
      this.video.stop();
    }
    
  }
  
  // call run() in draw function of parent sketch
  void run() {
    scale(this.scaleDownFactor);
    
    //image(introMovie, 0, 0);
    
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
    this.drawScanShape();
    this.drawDetected();
  }
  
  void toggleScanning() {
    println("Toggle Scanning");
    this.isScanning = ! this.isScanning;
  }
  
  void takePhoto() {
    println("takePhoto");
    //this.isPhotoToBeCaptured = true;
    this.stopVideoCapture();
    this.photoAnimationStartTime = millis();
    this.photoAnimationRunning = true;
  }
  
  void back() {
    println("back to main app / library");
  }
  
  void drawScanShape() {
    imageMode(CENTER);
    image(this.scanShape, width/(2*this.scaleDownFactor), height/(2*this.scaleDownFactor));
    imageMode(CORNER);
  }
  
  void drawDetected() {
    // draw rects around detected objects
    noFill();
    stroke(255, 255, 255, 100);
    //stroke(0, 255, 0);
    strokeWeight(1);  
    for (int i = 0; i < this.faces.length; i++) {
      //println(this.faces[i].x + "," + this.faces[i].y);
      rect(this.faces[i].x, this.faces[i].y, this.faces[i].width, this.faces[i].height);
    }
  }
  
  void drawGUI() {
    if(this.photoAnimationRunning){
      this.photoAnimationTimer = millis() - this.photoAnimationStartTime;
      //println(this.photoAnimationTimer);
      
      if (this.photoAnimationTimer < this.photoAnimationDuration) {
        drawPhotoAnimation(this.photoAnimationTimer, this.photoAnimationDuration);
      }
      
      if (this.photoAnimationTimer > (this.photoAnimationDuration + 500)) {
        // start video once
        println("play success video");
        if (!this.hasMovieStarted) {
          scanSuccessP.play();
          this.hasMovieStarted = true;
          this.photoAnimationRunning = false;
          this.photoAnimationTimer = -1;
        }
      }
    }
    
    if (this.hasMovieStarted){
      // display video continuously
      //image(scanSuccessP, 0, 0, width, height);
      imageMode(CENTER);
      image(scanSuccessP, width/2, height/2);
      imageMode(CORNER);
    }
    
    //TODO: back to start on video end
    //println(scanSuccessP.time());
    //if (myMovie.time() == myMovie.duration()) { 
      // movie must be finished
    //}
    
    drawHeader();
  }
  
  void drawHeader() {
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
  
  void drawPhotoAnimation(int timer, int duration) {
    //noStroke();
    fill(0);
    
    if(timer < duration/2) {
      // top
      rect(0,0, width, (1.0 * timer/duration) * height);
      // bottom
      rect(0,height, width, (-1.0 * timer/duration) * height);
    }
    else {
      // top
      rect(0,0, width, (1.0 * (duration - timer) / duration) * height);
      // bottom
      rect(0,height, width, (-1.0 * (duration - timer) / duration) * height);
    }
  } 
}

// read when new video frame is available
void captureEvent(Capture c) {
  c.read();
}

void movieEvent(Movie m) {
  m.read();
}