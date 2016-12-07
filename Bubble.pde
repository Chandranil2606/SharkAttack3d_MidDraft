class Bubble{

  float x;
  float y1;
  Bubble(float y){
      x = random(790);
      y1=y;
      
  }
  
  void bubbly(){
    // float y = random(0,800); 
      fill(0);
      ellipse(y1, x, 4, 4);
      x--;
    if(x<=5)
      x=790;
    
  }
  
}