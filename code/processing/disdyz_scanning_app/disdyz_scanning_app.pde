StringDict classifiers;
StringDict scanShapes;
LetterScanner scanner;

void setup() {
  size(640, 480);
  
  classifiers = new StringDict(new String[][] {
    {"P", sketchPath()+"/data/classifiers/cascade-P3.xml"},
  });
  
  scanShapes = new StringDict(new String[][] {
    {"P", sketchPath()+"/images/scanshapes/P.png"},
  });
  
  scanner = new LetterScanner(this, 640, 480, classifiers.get("P"), scanShapes.get("P"));
}

void draw() {  
  scanner.run();
}