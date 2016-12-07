class Leaf {
  PVector pos;
  boolean reached = false;

  Leaf() {
    pos = PVector.random3D();
    pos.mult(random(400));
    pos.x += width/2;
    pos.y += height/2;
  }

  void reached() {
    reached = true;
  }

  void show() {
    //fill(255);
    noStroke();
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    
    //fill(30,144,255);
    noFill();
    ellipse(0,0, 4, 4);
    popMatrix();
    
    
 
    
  }
}