HScrollbar hs1;
HScrollbar hs2;
HScrollbar hs3;
HScrollbar hs4;
HScrollbar hs5;

Button button1;
Button button2;
Button button3;
PImage car;
PImage output;
PImage temp;

public class Kernel {
  float[][] kernel;
  public Kernel(float[][] init) {kernel = init;}
  color pixelApply(PImage img, int x, int y) {
    if (x >= img.width - 1 || x < 1 || y >= img.height - 1 || y < 1) {return color(0, 0, 0);}
    else {
      float ar = 0; float ag = 0; float ab = 0;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          float r = red(img.get(x + (i - 1), y + (j - 1)));
          float g = green(img.get(x + (i - 1), y + (j - 1)));
          float b = blue(img.get(x + (i - 1), y + (j - 1)));
          r *= kernel[i][j]; g *= kernel[i][j]; b *= kernel[i][j];
         
          ar += r; ag += g; ab += b;
        }
      }
      ar = constrain(ar, 0, 255); ag = constrain(ag, 0, 255); ab = constrain(ab, 0, 255);
      return color(ar, ag, ab);
    }
  }
  void imageApply(PImage source, PImage destination) {
    for (int y = 0; y < source.height; y++) {
      for (int x = 0; x < source.width; x++) {
        destination.set(x, y, pixelApply(source, x, y));
      }
    }
  }
}

void saturateImage(float scale, PImage source, PImage destination) {
    for (int y = 0; y < source.height; y++) {
        for (int x = 0; x < source.width; x++) {
            destination.set(x, y, saturatePixel(scale, source, x, y));
    }
  }
  colorMode(RGB, 255);
}
void hueImage(float scale, PImage source, PImage destination) {
    for (int y = 0; y < source.height; y++) {
        for (int x = 0; x < source.width; x++) {
            destination.set(x, y, huePixel(scale, source, x, y));
    }
  }
  colorMode(RGB, 255);
}

color saturatePixel(float scale, PImage source, int x, int y) {
    colorMode(HSB, 255);
    float h = hue(source.get(x, y));
    float s = saturation(source.get(x, y));
    float l = brightness(source.get(x, y));
    return color(h, s + scale * 100, l);
}

color huePixel(float scale, PImage source, int x, int y) {
    colorMode(HSB, 255);
    float h = hue(source.get(x, y));
    float s = saturation(source.get(x, y));
    float l = brightness(source.get(x, y));
    return color(constrain(h + scale * 100, 0, 255), s, l);
}

class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    int y_lock = 0;
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
      y_lock = mouseY;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
      mouseY = y_lock;
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(0, 0, 0);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}


class Button {
  int swidth, sheight, text_offset;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  boolean over;           // is the mouse over the slider?
  String button_text;

  Button (float xp, float yp, int sw, int sh, String txt, int offset) {
    swidth = sw;
    sheight = sh;
    xpos = xp;
    ypos = yp-sheight/2;
    button_text = txt;
    text_offset = offset;
  }

  void update() {
   
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      if (button_text == "Reset") setup();
    }
    if (!mousePressed) {
     
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    if (over == true) {
      fill(100);
    } else {
      fill(50);
    }
    rect(xpos, ypos, swidth, sheight);
    fill(255);
    text(button_text, xpos+20 + text_offset, ypos+30);
  }

}



void apply(Kernel[] adjustments, PImage car, PImage output) {
  PImage temp = car.copy();
  for (int i = 0; i <= adjustments.length - 1; i++) {
    //print("Test of apply: " + i + "  ");
    adjustments[i].imageApply(temp, output);
    temp = output.copy();
  }
}

void draw() {
  background(255);
  stroke(0);
  line(0, height/2, width, height/2);
  //PImage car = loadImage("basquiat.jpeg");
  //if (car.height > 540) car.resize(0, 540);
  //if (car.width > 960) car.resize(960, 0);
  //PImage output = car.copy();
  //PImage temp = car.copy();
 
  output = car.copy();
  temp = car.copy();
 
  hs1.update();
  hs1.display();
  hs2.update();
  hs2.display();
  hs3.update();
  hs3.display();
  hs4.update();
  hs4.display();
  hs5.update();
  hs5.display();
  button1.update();
  button1.display();
  button2.update();
  button2.display();
  button3.update();
  button3.display();
 
 
  //convert hs1.spos to 0-1 scale factor
  float scale_factor = hs1.spos/width;
  float scale2 = hs2.spos/width * 2;
  float scale3 = hs3.spos/width * 2;
  float scale4 = hs4.spos/width * 5 - 2.5;
  float scale5 = hs5.spos/width * 5 - 2.5;
  //print("scale_factor: " + scale_factor + "  ");
  //print("scale2: " + scale2 + "  ");
 
  //apply emboss
 
 
  Kernel emboss = new Kernel(new float[][] {{-2 * scale_factor, -1 * scale_factor, 0 * scale_factor}, {-1 * scale_factor, 0 * scale_factor + 1, 1 * scale_factor}, {0 * scale_factor, 1 * scale_factor, 2 * scale_factor}});
  //apply brightness
 
  Kernel brightness = new Kernel(new float[][] { {0,0,0},{0, scale2, 0},{0,0,0}});
     
  Kernel sharpness = new Kernel(new float[][] {{0, -1 * scale3, 0},{-1 * scale3, 5*scale3, -1*scale3},{0, -1* scale3,0}});
 
  //emboss.imageApply(car,output);
  Kernel[] adjustments = new Kernel[3];
  adjustments[0] = emboss;
  adjustments[1] = brightness;
  adjustments[2] = sharpness;
  //apply(adjustments, car, output);
 
  emboss.imageApply(car, output);
  temp = output.copy();
  brightness.imageApply(temp, output);
  temp = output.copy();
  sharpness.imageApply(temp, output);
  temp = output.copy();
  saturateImage(scale4, temp, output);
  temp = output.copy();
  hueImage(scale5, temp, output);
  //apply(adjustments, output, output);
  image(car, 0, 0);
  image(output, car.width, 0);
  // labels
  textSize(16);
  fill(0, 0, 0);
  text("Emboss", width/2, height/2+25);
  textSize(16);
  text("Brightness", width/2, height/2+65);
  fill(0, 0, 0);
  textSize(16);
  text("Sharpness", width/2, height/2+105);
  fill(0, 0, 0);
  textSize(16);
  text("Saturation", width/2, height/2+145);
  fill(0, 0, 0);
  textSize(16);
  text("Hue", width/2, height/2+185);
  fill(0, 0, 0);  
  // buttons
   
  //rect(width/2-50, height/2+220, 100,50);
  //fill(255);
  //text("Reset", width/2-22, height/2+250);
  //float[] reset = new float[] {width/2-50, width/2+50, height/2+220, height/2+270};


}

void setup() {
  //PImage car = loadImage("basquiat.jpeg");
  // resize image if too large.
  car = loadImage("basquiat.jpeg");
  if (car.height > 540) car.resize(0, 540);
  if (car.width > 960) car.resize(960, 0);
  //PImage output = car.copy();
  output = car.copy();
  size(1920, 1080);
  Kernel emboss = new Kernel(new float[][] {{-2, -1 , 0}, {-1, 1, 1}, {0, 1, 2}});
  Kernel brightness = new Kernel(new float[][] {{0, 0, 0}, {0, 1, 0}, {0, 0, 0}});
  Kernel sharpness = new Kernel(new float[][] {{0, -1, 0}, {-1, 4, -1}, {0, -1, 0}});
  //emboss.imageApply(car,output);
  Kernel[] adjustments = new Kernel[2];
  adjustments[0] = emboss;
  adjustments[1] = brightness;
  apply(adjustments, car, output);
  //hs1 = new HScrollbar(0, height/2-8, width, 16, 16);
  hs1 = new HScrollbar(0, height/2 + 40, width, 16, 1);
  hs2 = new HScrollbar(0, height/2 + 80, width, 16, 1);
  hs3 = new HScrollbar(0, height/2 + 120, width, 16, 1);
  hs4 = new HScrollbar(0, height/2 + 160, width, 16, 1);
  hs5 = new HScrollbar(0, height/2 + 200, width, 16, 1);
  //text("word",width/2, height/2+8);
  button1 = new Button(width/2-50, height/2.0 + 245,  100, 50, "Reset", 7);
  button2 = new Button(width/2-50, height/2.0 + 315,  100, 50, "Save", 10);
  button3 = new Button(width/2-50, height/2.0 + 385,  100, 50, "Undo", 9);
  image(car, 0, 0);
  image(output, car.width, 0);
}
