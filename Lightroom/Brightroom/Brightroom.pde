HScrollbar hs1;
HScrollbar hs2;
HScrollbar hs3;
HScrollbar hs4;
HScrollbar hs5;
HScrollbar hs6;
HScrollbar hs7;
HScrollbar hs8;
HScrollbar hs9;
HScrollbar hs10;

boolean only_onebar = true;

Button button1;
Button button2;
Button button3;
Button button4;
Button button5; Button button6; Button button7; Button button8;

Button2 button_2_1;
Button2 button_2_2;
Button2 button_2_3;
Button2 button_2_4;
Button2 button_2_5;
Button2 button_2_6;
Button2 button_2_7;
Button2 button_2_8;
Button2 button_2_9;
Button2 button_2_10;

boolean hs1_switch = true;
boolean hs2_switch = true;
boolean hs3_switch = true;
boolean hs4_switch = true;
boolean hs5_switch = true;
boolean hs6_switch = true;
boolean hs7_switch = true;
boolean hs8_switch = true;
boolean hs9_switch = true;
boolean hs10_switch = true;

float adjustment_factor = 0.9887324;

boolean crop = false; boolean crop_rect = false;
int crop_x = 0; int crop_y = 0; int crop_xx = 0; int crop_yy = 0;

ArrayList<float[]> spos_list = new ArrayList<float[]>();

PImage car;
PImage car2;
PImage output;
PImage temp;
PImage forExport;

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
void highlightsImage(float scale, PImage source, PImage destination) {
    for (int y = 0; y < source.height; y++) {
        for (int x = 0; x < source.width; x++) {
            destination.set(x, y, highlightsPixel(scale, source, x, y));
    }
  }
  colorMode(RGB, 255);
}
void shadowsImage(float scale, PImage source, PImage destination) {
    for (int y = 0; y < source.height; y++) {
        for (int x = 0; x < source.width; x++) {
            destination.set(x, y, shadowsPixel(scale, source, x, y));
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
color highlightsPixel(float scale, PImage source, int x, int y) {
    colorMode(HSB, 255);
    float h = hue(source.get(x, y));
    float s = saturation(source.get(x, y));
    float l = brightness(source.get(x, y));
    float highlights = scale * 1.2 * l;
    return color(h, s, constrain(l+highlights, 0, 255));
}

color shadowsPixel(float scale, PImage source, int x, int y) {
    colorMode(HSB, 255);
    float h = hue(source.get(x, y));
    float s = saturation(source.get(x, y));
    float l = brightness(source.get(x, y));
    float shadows = scale * 1.2 * (255 - l);
    return color(h, s, constrain(l+shadows, 0, 255));
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

  HScrollbar (float xp, float yp, int sw, int sh, int l, float start, boolean undo, float spos_undo) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    if (!undo) {
      spos = start * (xpos + swidth/2 - sheight/2);
    } else {
      spos = spos_undo;
    }
    
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
    if (mousePressed && over && only_onebar) {
      locked = true;
      y_lock = mouseY;
      only_onebar = false;
    }
    if (!mousePressed) {
      locked = false;
      only_onebar = true;
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
  boolean button_once = true;

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
    if (mousePressed && over && button_once) {
      if (button_text == "Reset") setup();
      if (button_text == "Save") {
        float[] spos_t = {hs1.spos, hs2.spos, hs3.spos, hs4.spos, hs5.spos, hs6.spos, hs7.spos, hs8.spos, hs9.spos, hs10.spos};
        spos_list.add(spos_t);
        print(spos_list.size() + " ");
      }
      if (button_text == "Undo") {
        if (spos_list.size() > 0) {
          float[] spos_t = spos_list.remove(spos_list.size()-1);
          
          //print("save values are: " + spos_t[0] + " " + spos_t[1] + " " + spos_t[2] + " " + spos_t[3] + " " + spos_t[4]);
          hs1 = new HScrollbar(0, height/2 + 40, width-500, 16, 1, 0, true, spos_t[0]);
          hs2 = new HScrollbar(0, height/2 + 80, width-500, 16, 1, 1, true, spos_t[1]);
          hs3 = new HScrollbar(0, height/2 + 120, width-500, 16, 1, 1, true, spos_t[2]);
          hs4 = new HScrollbar(0, height/2 + 160, width-500, 16, 1, 1, true, spos_t[3]);
          hs5 = new HScrollbar(0, height/2 + 200, width-500, 16, 1, 1, true, spos_t[4]);
          hs6 = new HScrollbar(0, height/2 + 240, width-500, 16, 1, 1, true, spos_t[5]);
          hs7 = new HScrollbar(0, height/2 + 280, width-500, 16, 1, 0, true, spos_t[6]);    
          hs8 = new HScrollbar(0, height/2 + 320, width-500, 16, 1, 0, true, spos_t[7]);    
          hs9 = new HScrollbar(0, height/2 + 360, width-500, 16, 1, 0, true, spos_t[8]);    
          hs10 = new HScrollbar(0, height/2 + 400, width-500, 16, 1, 0, true, spos_t[9]);    
          
        } else {
          setup();
        }
        
      }
      if (button_text == "Export") {
        forExport.save("Export.tif");
      }
      if (button_text == "Vivid") {
          hs1 = new HScrollbar(0, height/2 + 40, width-500, 16, 1, 0, true, 0);
          hs2 = new HScrollbar(0, height/2 + 80, width-500, 16, 1, 1, true, 680);
          hs3 = new HScrollbar(0, height/2 + 120, width-500, 16, 1, 1, true, 850);
          hs4 = new HScrollbar(0, height/2 + 160, width-500, 16, 1, 1, true, 750);
          hs5 = new HScrollbar(0, height/2 + 200, width-500, 16, 1, 1, true, 702);
          hs6 = new HScrollbar(0, height/2 + 240, width-500, 16, 1, 1, true, 702);
          hs7 = new HScrollbar(0, height/2 + 280, width-500, 16, 1, 0, true, 0);    
          hs8 = new HScrollbar(0, height/2 + 320, width-500, 16, 1, 0, true, 750);    
          hs9 = new HScrollbar(0, height/2 + 360, width-500, 16, 1, 0, true, 750);    
          hs10 = new HScrollbar(0, height/2 + 400, width-500, 16, 1, 0, true, 900);
      }
      if (button_text == "Cinematic") {
          hs1 = new HScrollbar(0, height/2 + 40, width-500, 16, 1, 0, true, 0);
          hs2 = new HScrollbar(0, height/2 + 80, width-500, 16, 1, 1, true, 675);
          hs3 = new HScrollbar(0, height/2 + 120, width-500, 16, 1, 1, true, 775);
          hs4 = new HScrollbar(0, height/2 + 160, width-500, 16, 1, 1, true, 750);
          hs5 = new HScrollbar(0, height/2 + 200, width-500, 16, 1, 1, true, 702);
          hs6 = new HScrollbar(0, height/2 + 240, width-500, 16, 1, 1, true, 702);
          hs7 = new HScrollbar(0, height/2 + 280, width-500, 16, 1, 0, true, 0);    
          hs8 = new HScrollbar(0, height/2 + 320, width-500, 16, 1, 0, true, 730);    
          hs9 = new HScrollbar(0, height/2 + 360, width-500, 16, 1, 0, true, 600);    
          hs10 = new HScrollbar(0, height/2 + 400, width-500, 16, 1, 0, true, 675);
      }
          
      if (button_text == "Film") {
          hs1 = new HScrollbar(0, height/2 + 40, width-500, 16, 1, 0, true, 0);
          hs2 = new HScrollbar(0, height/2 + 80, width-500, 16, 1, 1, true, 650);
          hs3 = new HScrollbar(0, height/2 + 120, width-500, 16, 1, 1, true, 600);
          hs4 = new HScrollbar(0, height/2 + 160, width-500, 16, 1, 1, true, 0);
          hs5 = new HScrollbar(0, height/2 + 200, width-500, 16, 1, 1, true, 702);
          hs6 = new HScrollbar(0, height/2 + 240, width-500, 16, 1, 1, true, 702);
          hs7 = new HScrollbar(0, height/2 + 280, width-500, 16, 1, 0, true, 0);    
          hs8 = new HScrollbar(0, height/2 + 320, width-500, 16, 1, 0, true, 804);    
          hs9 = new HScrollbar(0, height/2 + 360, width-500, 16, 1, 0, true, 600);    
          hs10 = new HScrollbar(0, height/2 + 400, width-500, 16, 1, 0, true, 600);
      }
      if (button_text == "Sketch") {
          hs1 = new HScrollbar(0, height/2 + 40, width-500, 16, 1, 0, true, 1404);
          hs2 = new HScrollbar(0, height/2 + 80, width-500, 16, 1, 1, true, 702);
          hs3 = new HScrollbar(0, height/2 + 120, width-500, 16, 1, 1, true, 1404);
          hs4 = new HScrollbar(0, height/2 + 160, width-500, 16, 1, 1, true, 0);
          hs5 = new HScrollbar(0, height/2 + 200, width-500, 16, 1, 1, true, 702);
          hs6 = new HScrollbar(0, height/2 + 240, width-500, 16, 1, 1, true, 702);
          hs7 = new HScrollbar(0, height/2 + 280, width-500, 16, 1, 0, true, 0);    
          hs8 = new HScrollbar(0, height/2 + 320, width-500, 16, 1, 0, true, 750);    
          hs9 = new HScrollbar(0, height/2 + 360, width-500, 16, 1, 0, true, 750);    
          hs10 = new HScrollbar(0, height/2 + 400, width-500, 16, 1, 0, true, 1404);
      }
      button_once = false;
    }
    if (!mousePressed) {
      button_once = true;
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

class Button2 {
  int swidth, sheight, text_offset;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  boolean over;           // is the mouse over the slider?
  String button_text;
  String text = "on";
  boolean only_once = true;
  
  Button2(float xp, float yp, int sw, int sh, String txt, int offset) {
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
    if (mousePressed && over && only_once) {
      if (text == "on") {
        text = "off";
        if (button_text == "hs1") hs1_switch = false;
        if (button_text == "hs2") hs2_switch = false;
        if (button_text == "hs3") hs3_switch = false;
        if (button_text == "hs4") hs4_switch = false;
        if (button_text == "hs5") hs5_switch = false;
        if (button_text == "hs6") hs6_switch = false;
        if (button_text == "hs7") hs7_switch = false;
        if (button_text == "hs8") hs8_switch = false;
        if (button_text == "hs9") hs9_switch = false;
        if (button_text == "hs10") hs10_switch = false;
        only_once = false;
      } else {
        text = "on";
        if (button_text == "hs1") hs1_switch = true;
        if (button_text == "hs2") hs2_switch = true;
        if (button_text == "hs3") hs3_switch = true;
        if (button_text == "hs4") hs4_switch = true;
        if (button_text == "hs5") hs5_switch = true;
        if (button_text == "hs6") hs6_switch = true;
        if (button_text == "hs7") hs7_switch = true;
        if (button_text == "hs8") hs8_switch = true;
        if (button_text == "hs9") hs9_switch = true;
        if (button_text == "hs10") hs10_switch = true;
        only_once = false;
      }
    }
    if (!mousePressed) {
       only_once = true;
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
    text(text, xpos+15, ypos+16);
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

void crop_update() {
  if (mouseX > car.width && mouseX < (car.width + car2.width) && mouseY < car2.height) {
    if (!crop && mousePressed) {
      crop_x = mouseX; crop_y = mouseY;
      crop = true;
      crop_rect = true;
    }
    if (crop && mousePressed) {
      crop_xx = mouseX;
      crop_yy = mouseY;
    }
    
    if (crop && !mousePressed) {
      crop = false;
    }
  }
}

void crop_draw() {
  if (crop || crop_rect) {
    if (crop_xx > crop_x && crop_yy > crop_y) {
      stroke(0);
      noFill();
      rect(crop_x, crop_y, crop_xx-crop_x, crop_yy-crop_y);
      stroke(255);
      noFill();
      rect(crop_x+1, crop_y+1, crop_xx-crop_x-2, crop_yy-crop_y-2);
    } 
  }
}

void keyPressed() {
  if (!crop && crop_rect && key == ' ') {
    PImage temp_crop = car2.copy();
    temp_crop.resize(crop_xx - crop_x, crop_yy - crop_y);
    
    for (int i = 0; i < temp_crop.width; i++) {
      for (int j = 0; j < temp_crop.height; j++) {
        float r = red(car2.get(crop_x - car.width + i, crop_y + j));
        float g = green(car2.get(crop_x - car.width + i, crop_y + j));
        float b = blue(car2.get(crop_x - car.width + i, crop_y + j));
        
        temp_crop.set(i, j, color(r, g, b));
      }
    }
    car2 = temp_crop.copy();
    crop_reset();
  } else if (key == 'c') crop_reset();
}

void crop_reset() {
  crop = false;
  crop_rect = false;
  crop_x = crop_y = crop_xx = crop_yy = 0;
}

void rresize(float scale6, PImage source, PImage destination) {
  float new_scale = scale6; 
  float new_width = source.width;
  float new_height = source.height;
  
  if (source.width <= car.width && source.height <= car.height) {
    new_width = source.width * new_scale;
    new_height = source.height * new_scale;;
  } 
  
  float aspect_ratio = source.width * 1.0 / source.height;
  new_width = Math.max(new_width, 2);
  new_height = Math.max(new_height, 2);
  
  if (new_width > car.width) {
    new_width = car.width;
    new_height = new_width / aspect_ratio;
  }
  if (new_height > car.height) {
    new_height = car.height;
    new_width =  car.height * aspect_ratio;
  }
  destination.resize(Math.round(new_width), Math.round(new_height));
  
}

void bblur(float scale7, PImage source, PImage destination) {
  float blur_amount = 1 - scale7;
  float orig_width = Math.round(destination.width);
  float orig_height = Math.round(destination.height);
  destination.resize(Math.max(Math.round(source.width * blur_amount),1), Math.max(Math.round(source.height * blur_amount), 1));
  destination.resize((int)orig_width, (int)orig_height);
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
 
  output = car2.copy();
  temp = car2.copy();
 
  hs1.update(); hs1.display();
  hs2.update(); hs2.display();
  hs3.update(); hs3.display();
  hs4.update(); hs4.display();
  hs5.update(); hs5.display();
  hs6.update(); hs6.display();
  hs7.update(); hs7.display();
  hs8.update(); hs8.display();
  hs9.update(); hs9.display();
  hs10.update(); hs10.display();
  
  button1.update(); button1.display();
  button2.update(); button2.display();
  button3.update(); button3.display();
  button4.update(); button4.display();
  button5.update(); button5.display();
  button6.update(); button6.display();
  button7.update(); button7.display();
  button8.update(); button8.display();
 
 
  button_2_1.update(); button_2_1.display();
  button_2_2.update(); button_2_2.display();
  button_2_3.update(); button_2_3.display();
  button_2_4.update(); button_2_4.display();
  button_2_5.update(); button_2_5.display();
  button_2_6.update(); button_2_6.display();
  button_2_7.update(); button_2_7.display();
  button_2_8.update(); button_2_8.display();
  button_2_9.update(); button_2_9.display();
  button_2_10.update(); button_2_10.display();
 
 
  //convert hs1.spos to 0-1 scale factor
  float scale_factor = (hs1.spos/width) / adjustment_factor;
  float scale2 = ((hs2.spos/(width-500)) * 2) / adjustment_factor;
  float scale3 = ((hs3.spos/(width-500)) * 2 -1) / adjustment_factor;
  float scale4 = ((hs4.spos/(width-500)) * 5 - 2.5) / adjustment_factor;
  float scale5 = ((hs5.spos/(width-500)) * 5 - 2.5) / adjustment_factor;
  float scale6 = ((hs6.spos/(width-500)) * 2) / adjustment_factor;
  float scale7 = ((hs7.spos/(width-500))) / adjustment_factor;
  float scale8 = ((hs8.spos/(width-500)) * 2 - 1) / adjustment_factor;
  float scale9 = ((hs9.spos/(width-500)) * 2 - 1) / adjustment_factor;
  float scale10 = ((hs10.spos/(width-500)) * 2 - 1) / adjustment_factor;
  
  //apply emboss
  Kernel emboss = new Kernel(new float[][] {{-2 * scale_factor, -1 * scale_factor, 0 * scale_factor}, {-1 * scale_factor, 0 * scale_factor + 1, 1 * scale_factor}, {0 * scale_factor, 1 * scale_factor, 2 * scale_factor}});
  //apply brightness
 
  Kernel brightness = new Kernel(new float[][] { {0,0,0},{0, scale2, 0},{0,0,0}});
     
  Kernel sharpness = new Kernel(new float[][] {{0, -1 * scale3, 0},{-1 * scale3, 4*scale3+1, -1*scale3},{0, -1* scale3,0}});
 
  //emboss.imageApply(car,output);
  Kernel[] adjustments = new Kernel[3];
  adjustments[0] = emboss;
  adjustments[1] = brightness;
  adjustments[2] = sharpness;
  //apply(adjustments, car, output);
  if (hs1_switch) {
    emboss.imageApply(car2, output);
    temp = output.copy();
  }
  if (hs2_switch) {
    brightness.imageApply(temp, output);
    temp = output.copy();
  }
  if (hs3_switch) {
    sharpness.imageApply(temp, output);
    temp = output.copy();
  }
  if (hs4_switch) {
    saturateImage(scale4, temp, output);
    temp = output.copy();
  }
  if (hs5_switch) {
    hueImage(scale5, temp, output);
    temp = output.copy();
  } 
  if (hs6_switch) {
    rresize(scale6, temp, output);
    temp = output.copy();
  }
  if (hs7_switch) {
    bblur(scale7, temp, output);
    temp = output.copy();
  }
  if (hs8_switch) {
    highlightsImage(scale8, temp, output);
    temp = output.copy();
    //print(scale8 + "     ");
  }
  if (hs9_switch) {
    shadowsImage(scale9, temp, output);
    temp = output.copy();
    //print(scale9 + "     ");
  }
  if (hs10_switch) {
    highlightsImage(scale10, temp, output);
    temp = output.copy();
    shadowsImage(-scale10, temp, output);
    temp = output.copy();
    //print(scale10 + "     ");
  }
  // save copy of altered image for export
  forExport = output.copy();
  
  //apply(adjustments, output, output);
  image(car, 0, 0);
  image(output, car.width, 0);
  
  fill(50);
  text("Controls", width-383, height/2+60);
  text("Presets", width-260, height/2+60);
  
  crop_update();
  crop_draw();
  // labels
  textSize(16);
  fill(0, 0, 0);
  text("Emboss", width/2-280, height/2+25);
  text("Brightness", width/2-280, height/2+65);
  fill(0, 0, 0);
  text("Sharpness", width/2-280, height/2+105);
  fill(0, 0, 0);
  text("Saturation", width/2-280, height/2+145);
  fill(0, 0, 0);
  text("Hue", width/2-280, height/2+185);
  fill(0, 0, 0);
  text("Resize", width/2-280, height/2+225);
  fill(0, 0, 0);
  text("Blur", width/2-280, height/2+265);
  fill(0, 0, 0);
  text("Highlights", width/2-280, height/2+305);
  fill(0, 0, 0);
  text("Shadows", width/2-280, height/2+345);
  fill(0, 0, 0);
  text("Contrast", width/2-280, height/2+385);
  fill(0, 0, 0);

}

void setup() {
  //PImage car = loadImage("basquiat.jpeg");
  // resize image if too large.
  car = loadImage("temple2.jpg");
  if (car.height > 540) car.resize(0, 540);
  if (car.width > 960) car.resize(960, 0);
  //PImage output = car.copy();
  output = car.copy();
  car2 = car.copy();
  forExport = car.copy();
  size(1920, 1080);
  Kernel emboss = new Kernel(new float[][] {{-2, -1 , 0}, {-1, 1, 1}, {0, 1, 2}});
  Kernel brightness = new Kernel(new float[][] {{0, 0, 0}, {0, 1, 0}, {0, 0, 0}});
  Kernel sharpness = new Kernel(new float[][] {{0, -1, 0}, {-1, 4, -1}, {0, -1, 0}});
  //emboss.imageApply(car,output);
  Kernel[] adjustments = new Kernel[2];
  adjustments[0] = emboss;
  adjustments[1] = brightness;
  //apply(adjustments, car, output);  don't apply effects at first. 
  //hs1 = new HScrollbar(0, height/2-8, width, 16, 16);
  hs1 = new HScrollbar(0, height/2 + 40, width-500, 16, 1, 0, false, 0);
  hs2 = new HScrollbar(0, height/2 + 80, width-500, 16, 1, 1, false, 0);
  hs3 = new HScrollbar(0, height/2 + 120, width-500, 16, 1, 1, false, 0);
  hs4 = new HScrollbar(0, height/2 + 160, width-500, 16, 1, 1, false, 0);
  hs5 = new HScrollbar(0, height/2 + 200, width-500, 16, 1, 1, false, 0);
  hs6 = new HScrollbar(0, height/2 + 240, width-500, 16, 1, 1, false, 0);
  hs7 = new HScrollbar(0, height/2 + 280, width-500, 16, 1, 0, false, 0);
  hs8 = new HScrollbar(0, height/2 + 320, width-500, 16, 1, 1, false, 0);
  hs9 = new HScrollbar(0, height/2 + 360, width-500, 16, 1, 1, false, 0);
  hs10 = new HScrollbar(0, height/2 + 400, width-500, 16, 1, 1, false, 0);
  
  //text("word",width/2, height/2+8);
  
  
  button1 = new Button(width - 400, height/2 + 100,  100, 50, "Reset", 7);
  button2 = new Button(width - 400, height/2.0 + 170,  100, 50, "Save", 10);
  button3 = new Button(width - 400, height/2.0 + 240,  100, 50, "Undo", 9);
  button4 = new Button(width - 400, height/2.0 + 310,  100, 50, "Export", 5);
  
  button5 = new Button(width - 280, height/2 + 100,  100, 50, "Vivid", 10);
  button6 = new Button(width - 280, height/2.0 + 170,  100, 50, "Cinematic", -9);
  button7 = new Button(width - 280, height/2.0 + 240,  100, 50, "Film", 12);
  button8 = new Button(width - 280, height/2.0 + 310,  100, 50, "Sketch", 4);
 
 
  button_2_1 = new Button2(width - 490, height/2.0 + 40, 50,20, "hs1", 0);
  button_2_2 = new Button2(width - 490, height/2.0 + 80, 50,20, "hs2", 0);
  button_2_3 = new Button2(width - 490, height/2.0 + 120, 50,20, "hs3", 0);
  button_2_4 = new Button2(width - 490, height/2.0 + 160, 50,20, "hs4", 0);
  button_2_5 = new Button2(width - 490, height/2.0 + 200, 50,20, "hs5", 0);
  button_2_6 = new Button2(width - 490, height/2.0 + 240, 50,20, "hs6", 0);
  button_2_7 = new Button2(width - 490, height/2.0 + 280, 50,20, "hs7", 0);
  button_2_8 = new Button2(width - 490, height/2.0 + 320, 50,20, "hs8", 0);
  button_2_9 = new Button2(width - 490, height/2.0 + 360, 50,20, "hs9", 0);
  button_2_10 = new Button2(width - 490, height/2.0 + 400, 50,20, "hs10", 0);
  
  hs1_switch = hs2_switch = hs3_switch = hs4_switch = hs5_switch = hs6_switch = hs7_switch = hs8_switch = hs9_switch = hs10_switch = true;
  
  image(car, 0, 0);
  image(output, car.width, 0);
}
