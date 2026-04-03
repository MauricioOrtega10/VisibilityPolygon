/**
 * 2D Visibility Polygon Simulation
 * --------------------------------------
 * This program calculates and renders the visibility polygon from a light source 
 * (the mouse) within a field of static rectangular obstacles.
 */

ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
ArrayList<PVector> points = new ArrayList<PVector>();

void setup() 
{
  size(800, 600);
  generateEnvironment();
}

void draw() 
{
  background(25);
  
  // Render all environment obstacles
  fill(60); stroke(100); strokeWeight(2);
  for (Obstacle obs : obstacles) 
  {
    obs.display();
  }

  points.clear();
  
  // 1. SCANNINIG PHASE: Collect all relevant vertices for ray casting
  for (Obstacle obs : obstacles) 
  {
    for (PVector v : obs.vertices) 
    {
      float angle = atan2(v.y - mouseY, v.x - mouseX);
      // We cast 3 rays per vertex (slight offset) to "hug" the corners and 
      // capture the empty space behind them.
      addRayPoint(angle);
      addRayPoint(angle - 0.001); 
      addRayPoint(angle + 0.001);
    }
  }
  
  // Include the 4 screen corners to ensure the polygon reaches the canvas edges
  addRayPoint(atan2(0 - mouseY, 0 - mouseX));
  addRayPoint(atan2(0 - mouseY, width - mouseX));
  addRayPoint(atan2(height - mouseY, width - mouseX));
  addRayPoint(atan2(height - mouseY, 0 - mouseX));

  // 2. SORTING PHASE: Sort points by angle relative to the mouse 
  // This is crucial for beginShape() to connect vertices in the correct order.
  points.sort((a, b) -> Float.compare(atan2(a.y - mouseY, a.x - mouseX), 
                                      atan2(b.y - mouseY, b.x - mouseX)));

  // 3. RENDERING PHASE: Draw the resulting translucent visibility field
  noStroke();
  fill(100, 255, 100, 120); // Translucent green glow
  beginShape();
  for (PVector p : points) 
  {
    vertex(p.x, p.y);
  }
  endShape(CLOSE);
  
  // Draw the "Robot" / Light Source
  fill(255, 0, 0); noStroke();
  ellipse(mouseX, mouseY, 12, 12);
}

/**
 * Procedurally generates a set of non-overlapping rectangular obstacles.
 */
void generateEnvironment() 
{
  obstacles.clear();
  int maxObstacles = 8;
  int maxAttempts = 200; // Fail-safe to avoid infinite loops if space is tight
  
  for (int i = 0; i < maxObstacles; i++) 
  {
    boolean overlapping = true;
    int attempts = 0;
    
    while (overlapping && attempts < maxAttempts) 
    {
      float w = random(60, 120);
      float h = random(60, 120);
      float x = random(50, width - 150);
      float y = random(50, height - 150);
      
      Obstacle newObstacle = new Obstacle(x, y, w, h);
      overlapping = false;
      
      // Check collision against existing geometry
      for (Obstacle existing : obstacles) 
      {
        if (checkRectCollision(newObstacle, existing)) 
        {
          overlapping = true;
          break;
        }
      }
      
      // Ensure the source isn't spawned inside an obstacle
      if (mouseX > newObstacle.x && mouseX < newObstacle.x + newObstacle.w && 
          mouseY > newObstacle.y && mouseY < newObstacle.y + newObstacle.h) 
      {
        overlapping = true;
      }
      
      if (!overlapping) obstacles.add(newObstacle);
      attempts++;
    }
  }
}

/** 
 * Standard AABB (Axis-Aligned Bounding Box) collision check 
 */
boolean checkRectCollision(Obstacle a, Obstacle b) 
{
  return a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y;
}

void mousePressed() 
{
  generateEnvironment();
}

/**
 * Projects a ray from the mouse position in the given angle and 
 * finds the closest intersection with any obstacle.
 */
void addRayPoint(float angle) 
{
  float x2 = mouseX + cos(angle) * 2000; // Ray projected to "infinity"
  float y2 = mouseY + sin(angle) * 2000;
  
  PVector closest = new PVector(x2, y2);
  float minDist = 2000;

  for (Obstacle obs : obstacles) 
  {
    PVector intersect = obs.getIntersection(mouseX, mouseY, x2, y2);
    if (intersect != null) 
    {
      float d = dist(mouseX, mouseY, intersect.x, intersect.y);
      if (d < minDist) 
      {
        minDist = d;
        closest = intersect;
      }
    }
  }
  points.add(closest);
}

// --- OBSTACLE CLASS ---
class Obstacle 
{
  float x, y, w, h;
  PVector[] vertices = new PVector[4];

  Obstacle(float x, float y, float w, float h) 
  {
    this.x = x; this.y = y; this.w = w; this.h = h;
    vertices[0] = new PVector(x, y);
    vertices[1] = new PVector(x + w, y);
    vertices[2] = new PVector(x + w, y + h);
    vertices[3] = new PVector(x, y + h);
  }

  void display() 
  {
    rect(x, y, w, h);
  }

  /**
   * Calculates the closest intersection point between a ray (r1 to r2)
   * and the four segments of this rectangular obstacle.
   */
  PVector getIntersection(float r1x, float r1y, float r2x, float r2y) 
  {
    PVector closestHit = null;
    float dClosest = 1000000;

    for (int i = 0; i < 4; i++) 
    {
      PVector v1 = vertices[i];
      PVector v2 = vertices[(i + 1) % 4];
      
      // Segment-Ray intersection algorithm
      float den = (v2.y - v1.y) * (r2x - r1x) - (v2.x - v1.x) * (r2y - r1y);
      if (den == 0) continue; // Parallel lines

      float ua = ((v2.x - v1.x) * (r1y - v1.y) - (v2.y - v1.y) * (r1x - v1.x)) / den;
      float ub = ((r2x - r1x) * (r1y - v1.y) - (r2y - r1y) * (r1x - v1.x)) / den;

      // Check if intersection occurs within both segments
      if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) 
      {
        PVector hit = new PVector(r1x + ua * (r2x - r1x), r1y + ua * (r2y - r1y));
        float d = dist(r1x, r1y, hit.x, hit.y);
        if (d < dClosest) 
        {
          dClosest = d;
          closestHit = hit;
        }
      }
    }
    return closestHit;
  }
}
