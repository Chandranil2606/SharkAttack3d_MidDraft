
// hunter.pde

class Hunter 
{
  PVector loc;        // location
  PVector vel;        // velocity
  PVector acc;        // acceleration
  float rbl;          // border limit
  float maxforce;     // maximum steering force
  float maxspeed;     // maximum speed
  float maxVertspeed; // maximum vertical speed 

  // constructor
  Hunter (PVector location, float max_speed, float max_force) 
  {
    acc = new PVector(0, 0, 0);
    vel = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
    loc = location.get();
    rbl = 16.0;
    maxspeed = max_speed;
    maxforce = max_force;
    maxVertspeed = max_speed/10;
  }

  void animate(ArrayList boids, ArrayList hunters) 
  {
    flock(boids, hunters);
    update(boids);
  }
  
  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList boids, ArrayList hunters) 
  {
    PVector sep = separate(hunters);   // Separation
    PVector hnt = hunt(boids);
    
    // Arbitrarily weight these forces
    sep.mult(1.1);
    hnt.mult(1.0);
    
    // Add the force vectors to acceleration
    acc.add(sep);
    acc.add(hnt);
  }
  
  // Method to update location
  void update(ArrayList boids) 
  {
    // Update velocity
    vel.add(acc);
    // Limit speed
    vel.limit(maxspeed);
    if(vel.z>maxVertspeed) vel.z=maxVertspeed;
    if(vel.z<-maxVertspeed) vel.z=-maxVertspeed;
   
    loc.add(vel);
    // Reset accelertion to 0 each cycle
    acc.mult(0);
  }

  // draw hunter rotated in the direction of velocity
  void render() 
  {
    PVector heading = new PVector(vel.x, vel.y);
    heading.normalize();
    float theta = heading.heading2D() + PI/2;
    pushMatrix();
      rotateX(PI/2);
      translate(loc.x, loc.y, loc.z);
      rotate(theta);
      shape(sharkShape);
    popMatrix();
  }

  PVector hunt(ArrayList boids) 
  {
    float neighbordist = 1200.0;
    PVector sum = new PVector(0, 0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) 
    {
      Boid other = (Boid) boids.get(i);
      float d = loc.dist(other.loc);
     
      if ((d > rbl) && (d < neighbordist)) 
      {
        sum.add(other.loc); // Add location
        count++;
      } 
      else if (d < rbl) 
      {
        boids.remove(i);
        println("one fish killed, "+boids.size() + " fishes remaining");
      }
    }
    if (count > 0)
    {
      sum.div((float)count);
      return steer(sum, false);  // Steer towards the location
    }
    return sum;  // Steer towards the location
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList hunters)
  {
    float desiredseparation = 200.0;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (int i = 0 ; i < hunters.size(); i++) 
    {
      Hunter other = (Hunter)  hunters.get(i);
      float d = PVector.dist(loc, other.loc);

      // changed to hold flock together
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation/3)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(loc, other.loc);
        diff.normalize();
        diff.div(d*20);     // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }

      if ((d > 0) && (d < desiredseparation)) 
      {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(loc, other.loc);
        diff.normalize();
        diff.div(d/2);      // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0)
      steer.div((float)count);

    // As long as the vector is greater than 0
    if (steer.mag() > 0) 
    {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Wraparound
  void borders() 
  {
    float wbl = width * 0.3 - rbl;
    float hbl = height* 0.3 - rbl;
    if (loc.x < rbl) loc.x = wbl;
    if (loc.y < rbl) loc.y = hbl;
    if (loc.x > wbl) loc.x = rbl;
    if (loc.y > hbl) loc.y = rbl;
    if (loc.z < rbl) loc.z = hbl;
    if (loc.z > hbl) loc.z = rbl;
  }

  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  PVector steer(PVector target, boolean slowdown) 
  {
    PVector steer;  // The steering vector
    PVector desired = target.sub(target, loc);  // A vector pointing from the location to the target
    float d = desired.mag(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) 
    {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if ((slowdown) && (d < 100.0)) desired.mult(maxspeed*(d/100.0)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = target.sub(desired, vel);
      steer.limit(maxforce);  // Limit to maximum steering force
    } 
    else steer = new PVector(0, 0, 0);
    return steer;
  }
}