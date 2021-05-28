public class Kernel {
  float[][]kernel;
  public Kernel(float[][]init) {
   kernel = init;
  }
  color calcNewColor(PImage img, int x, int y) {
    if (x >= img.width-1 || x  < 1 || y  >= img.height-1 || y < 1) {
      return color(0, 0, 0);
    }
    else {
      float new_r = 0;
      float new_g = 0;
      float new_b = 0;
      for (int i = 0; i<3; i++) {
        for (int j = 0; j < 3; j++) {
           float now_r = red(img.get(x + (i-1), y + (j-1)));
           float now_g = green(img.get(x + (i-1), y + (j-1)));
           float now_b = blue(img.get(x + (i-1), y + (j-1)));
           now_r *= kernel[i][j];
           now_g *= kernel[i][j];
           now_b *= kernel[i][j];
           new_r += now_r;
           new_g += now_g;
           new_b += now_b;         
        }
      }
      new_r = constrain(new_r, 0, 255);
      new_g = constrain(new_g, 0, 255);
      new_b = constrain(new_b, 0, 255);
      return color(new_r, new_g, new_b);
    }
  }
  void apply(PImage source, PImage destination) {
     for (int y = 0; y<source.height;y++){
     for (int x = 0; x<source.width;x++) {
     destination.set(x, y, calcNewColor(source, x, y));
}
}
  }
}

void test1(Kernel[] adjustments, PImage car, PImage output) {
  for (int i = 0; i < adjustments.length - 1; i++) {
     adjustments[i].apply(car, output);
   }
}


void setup(){
  size(1450,500);
  PImage car = loadImage("redcar.jpg");
  PImage output = car.copy();
  Kernel emboss = new Kernel(new float[][] {{-2, -1, 0},{-1, 1, 1},{0, 1, 2}});
  //emboss.apply(car,output);
  Kernel[] adjustments = new Kernel[1];
  adjustments[0] = emboss;
  image(car,0,0);
  image(output,car.width,0);
  
  test1(adjustments, car, output);
}
