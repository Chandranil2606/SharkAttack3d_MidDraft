
// flock.pde:   The Flock handles all fishes

class Flock 
{
  ArrayList fishes;    // list of all the fishes

  Flock() 
  {
    fishes = new ArrayList();  // create ArrayList
  }

  // animate fishes
  void animate (ArrayList sharks) 
  {
    for (int i = 0; i < fishes.size(); i++) 
    {
      Boid fish = (Boid) fishes.get(i);  
      fish.animate(fishes, sharks);  // Passing the entire list of fishes to each fish individually
    }
  }

  // draw all fishes of the flock
  void render() 
  {
    for (int i = 0; i < fishes.size(); i++) 
    {
      Boid fish = (Boid) fishes.get(i);  
      fish.render();  // Passing the entire list of fishes to each fish individually
    }
  }

  void addFishes (int count)
  {
    for (int i = 0; i < count; i++) 
      fishes.add(new Boid(new PVector(width*random(-1, 1), height*random(-1, 1), height*random(-0.5, 0.5)), 15.0, 0.5));
  }

  void remove(int count)
  {
    for (int i = 0; i < count; i++) 
    {
      int ai = flock.fishes.size(); 
      if (ai > 1)
        fishes.remove(ai-1);
    }
  }
}