HScrollbar hs1;
HScrollbar hs2;
HScrollbar hs3;
HScrollbar hs4;
HScrollbar hs5;
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
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
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
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}

void apply(Kernel[] adjustments, PImage car, PImage output) {
  for (int i = 0; i <= adjustments.length - 1; i++) {
    //print("Test of apply: " + i + "  ");
    adjustments[i].imageApply(car, output);
  }
}

void draw() {
  background(255);
  stroke(0);
  line(0, height/2, width, height/2);
  PImage car = loadImage("redcar.jpg");
  PImage output = car.copy();
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
  //convert hs1.spos to 0-1 scale factor
  float scale_factor = hs1.spos/width;
  float scale2 = hs2.spos/width * 2;
  float scale3 = hs3.spos/width * 2;
  //print("scale_factor: " + scale_factor + "  ");
  //print("scale2: " + scale2 + "  ");
  
  //apply emboss
  
  float[][] conv = new float[][] {{-2 * scale_factor, -1 * scale_factor, 0 * scale_factor}, {-1 * scale_factor, 0 * scale_factor + 1, 1 * scale_factor}, {0 * scale_factor, 1 * scale_factor, 2 * scale_factor}};
  
  Kernel emboss = new Kernel(conv);
  //Kernel emboss = new Kernel(new float[][] {{-2 * scale_factor, -1 * scale_factor, 0 * scale_factor}, {-1 * scale_factor, 0 * scale_factor + 1, 1 * scale_factor}, {0 * scale_factor, 1 * scale_factor, 2 * scale_factor}});
  //apply brightness
  conv[1][1] *= scale2;
  //Kernel brightness = new Kernel(new float[][] {{-2 * scale_factor, -1 * scale_factor, 0 * scale_factor}, {-1 * scale_factor, (0 * scale_factor + 1) * scale2, 1 * scale_factor}, {0 * scale_factor, 1 * scale_factor, 2 * scale_factor}});
  Kernel brightness = new Kernel(conv);
  
  //apply sharpness
  conv[0][0] = 0; conv[0][1] *= (-1 * scale3); conv[0][2] = 0;
  conv[1][0] *= (-1 * scale3); conv[1][1] *= (4 * scale3); conv[1][2] *= (-1 * scale3);
  conv[2][0] = 0; conv[2][1] *= (-1 * scale3); conv[2][2] = 0;
  
  Kernel sharpness = new Kernel(conv);
  
  //emboss.imageApply(car,output);
  Kernel[] adjustments = new Kernel[3];
  adjustments[0] = emboss;
  adjustments[1] = brightness;
  adjustments[2] = sharpness;
  apply(adjustments, car, output);
  //apply(adjustments, output, output);
  image(car, 0, 0);
  image(output, car.width, 0);
  // labels
  textSize(16);
  text("Emboss", width/2, height/2+20); 
  fill(0, 102, 153);
  textSize(16);
  text("Brightness", width/2, height/2+65); 
  fill(0, 102, 153);
  textSize(16);
  text("Sharpness", width/2, height/2+105); 
  fill(0, 102, 153);
  textSize(16);
  text("Emboss", width/2, height/2+145); 
  fill(0, 102, 153);
  textSize(16);
  text("Emboss", width/2, height/2+185); 
  fill(0, 102, 153);
  
}

void setup() {
  PImage car = loadImage("redcar.jpg");
  PImage output = car.copy();
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
  hs1 = new HScrollbar(0, height/2 + 40, width, 16, 8);
  hs2 = new HScrollbar(0, height/2 + 80, width, 16, 8);
  hs3 = new HScrollbar(0, height/2 + 120, width, 16, 8);
  hs4 = new HScrollbar(0, height/2 + 160, width, 16, 8);
  hs5 = new HScrollbar(0, height/2 + 200, width, 16, 8);
  //text("word",width/2, height/2+8);
  image(car, 0, 0);
  image(output, car.width, 0);
}
