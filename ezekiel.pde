//Import a bunch of things
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.util.Date;
import javax.swing.JFrame;
import javax.swing.JFileChooser;
import java.awt.event.WindowEvent;

//Create a World object to hold everything
World world;

//Global variables
int     START_PARTICLES = 1500;
float   MAX_SPEED       = 4.0;
float   PSIZE           = 1;
float   PA_STRENGTH     = 40.0;
int     DRAW_MODE       = 'A';
boolean HELP_MODE       = false;
boolean STATS_MODE      = true;
String  EDGE_MODE       = "wrap";
boolean TRAILS_MODE     = false;

//Setup the world
void setup() {
  size(600,600);
  
  //Create particle and physics actor lists to pass to the world constructor
  //and then create the world.
  List<Particle> pl = new ArrayList<Particle>();
  List<PhysicsActor> aL = new ArrayList<PhysicsActor>();
  world = new World(pl, aL);
  world.resetParticles();
}

//Draw the screen
void draw() {
  //If trails are on, draw the background lightly, if not, draw it at full opacity.
  if(TRAILS_MODE) {
    fill(255,255,255,100);
    rect(0,0,width,height);
    fill(0,0,0,0);
  } else {
     background(255);
  }
  
  //Update the world
  world.tick();
 
  //Display stats/help screens  
  PFont f = createFont("Arial",16,true);
  textFont(f,16);
  if(STATS_MODE) {
    showStats(20, height - 80);
  }
  if(HELP_MODE) {
    drawMenu(20,30); 
  }
}


//Handle adding actors to the screen
void mousePressed() {
  switch (mouseButton) {
    case LEFT:
      world.addActor(actorFactory());
      break;
    case RIGHT:
      world.clearActors();
      break;
  }
}

//Handle keyboard controls (stupidly complicated, sorry)
void keyPressed() {
  switch (keyCode) {
    case 'A':
    case 'S':
    case 'Q':
    case 'W':
      DRAW_MODE = keyCode;
      break;
    case 'R':
      MAX_SPEED -= 1;
      break;
    case 'T':
      MAX_SPEED += 1;
      break;
    case 'F':
      PSIZE -= 1;
      break;
    case 'G':
      PSIZE += 1;
      break;
    case ' ':
      //background(255);
      world.resetParticles();
      break;
    case 'H':
      if(HELP_MODE) { HELP_MODE = false; } else { HELP_MODE = true; } 
      break;
    case 'B':
      if(EDGE_MODE.equals("wrap")) { EDGE_MODE = "bounce"; } else { EDGE_MODE = "wrap"; }
      break;
    case 'Z':
      if(STATS_MODE) { STATS_MODE = false; } else { STATS_MODE = true; }
      break;
    case 'P':
      saveFrame("img######.png");
      break;
    case 'L':
      if(TRAILS_MODE) { TRAILS_MODE = false; } else { TRAILS_MODE = true; }
      break;
    case 'X':
      world.saveFile();
      break;
    case 'C':
      world.loadFile();
    default:
      break;
  }
}

//Function to display the world stats
void showStats(int x, int y) {
  text("Particle Speed: " + MAX_SPEED, x, y);
  text("Particle Size: " + PSIZE, x, y + 20);
  text("Edge Mode: " + EDGE_MODE.toUpperCase(), x, y + 40);
  text("Draw Mode: " + getDrawMode(), x, y + 60);
}

//Function which returns the drawing mode to the stats display
String getDrawMode() {
  switch(DRAW_MODE) {
    case 'A':
      return "Attractor";
    case 'S':
      return "Repulsor";
    case 'Q':
      return "Clockwise";
    case 'W':
      return "Counterclockwise";
    default:
      return null;
  } 
}

//Function which draws the help menu
void drawMenu(int x, int y) {
  fill(100,100,100,200);
  rect(0,0,width,height);
  fill(255,255,255);
  text("PHYSICS CONTROLS", x, y);
  text("A - clicking creates attractors", x + 30, y + 20);
  text("S - clicking creates repulsors", x + 30, y + 40);
  text("Q - clicking creates clockwise rotators", x + 30, y + 60);
  text("W - clicking creates counterclockwise rotators", x + 30, y + 80);
  text("Right Click - delete all physics actors", x + 30, y + 100);
  text("PARTICLE CONTROLS", x, y + 140);
  text("R - decrement particle top speed", x + 30, y + 160);
  text("T - increment particle top speed", x + 30, y + 180);
  text("F - decrement particle size", x + 30, y + 200);
  text("G - increment particle size", x + 30, y + 220);
  text("L - toggle particle trails", x + 30, y + 240);
  text("SPACE - reset particles", x + 30, y + 260);
  text("GENERAL", x, y + 300);
  text("H - toggle help screen", x + 30, y + 320);
  text("Z - toggle stats readout", x + 30, y + 340);
  text("B - toggle edge style", x + 30, y + 360);
  text("P - save screen capture", x + 30, y + 380);
  text("X - save simulator state", x + 30, y + 400);
  text("C - load simulator state", x + 30, y + 420);
  text("D - a big fat D.", x + 30, y + 440);
  fill(0,0,0,0); 
}

//Function which returns a new PhysicsActor depending on what draw mode we're in.
PhysicsActor actorFactory() {
  switch (DRAW_MODE) {
    case 'A':
      return new Attractor(new PVector(mouseX, mouseY), PA_STRENGTH);
    case 'Q':
      return new Rotator(new PVector(mouseX, mouseY), PA_STRENGTH);
    case 'S':
      return new Attractor(new PVector(mouseX, mouseY), -PA_STRENGTH);
    case 'W':
      return new Rotator(new PVector(mouseX, mouseY), -PA_STRENGTH);
    default:
      return null;
  }
}

// World is... the world.  It runs the attractrors which run the particles.
private class World {
  private List<Particle> m_particles;
  private List<PhysicsActor> m_actors;
  
  //Constructor
  public World(List<Particle> p, List<PhysicsActor> a) {
    m_particles = p;
    m_actors = a;
  }
  
  //Adds an actor to the world
  public void addActor(PhysicsActor a) {
    m_actors.add(a);
  }
  
  //Adds a particle to the world
  public void addParticle(Particle p) {
    m_particles.add(p); 
  }
  
  //Resets the particles to random location/velocity
  public void resetParticles() {
    List<Particle> part = new ArrayList<Particle>(START_PARTICLES);
    for(int i = 0;i < START_PARTICLES; i++) {
      PVector position = new PVector(random(width),random(height));
      part.add(new Particle(position));
    }
    m_particles = part;
  }
  
  //Clears all actors
  public void clearActors() {
    m_actors.clear();
  }
  
  public void clearParticles() {
    m_particles.clear();
  }
  
  //Handles the majority of world actions
  void tick() {
    // draw all actors
    Iterator<PhysicsActor> i = m_actors.iterator();
    PhysicsActor a;
    while (i.hasNext()) { 
      a = i.next();
      a.drawSelf();
    }
    
    // for each particle, update from all actors
    Iterator<Particle> ip = m_particles.iterator();
    Particle p;
    while (ip.hasNext()) {
      p = ip.next();
      
      i = m_actors.iterator();
      while (i.hasNext()) { 
        a = i.next();
        a.actOn(p);
      }
      
      p.update();
    }
  }
 
  //Writes data about particles and actors to a file
  private void saveFile() {
    Iterator<Particle> pi = m_particles.iterator();
    Iterator<PhysicsActor> ai = m_actors.iterator();
    Particle particle;
    PhysicsActor physicsActor;
    try {
      File file = filePrompt(true);
      // returns if there was no file selected (this should probably say something)
      if (file == null) return;
      
      if(!file.exists()) {
        file.createNewFile();
      }
     
      FileWriter fw = new FileWriter(file.getAbsoluteFile());
      BufferedWriter bw = new BufferedWriter(fw);
      bw.write("SPD\n");
      bw.write(MAX_SPEED + "\n");
      while(ai.hasNext()) {
        physicsActor = ai.next();
        bw.write(physicsActor.asString());
      }
      while(pi.hasNext()) {
        particle = pi.next();
        bw.write(particle.asString()); 
      }
      bw.close();
      } catch (IOException e) {
       e.printStackTrace();
    }
  }
  
  //Reads from a file the world data and updates the world
  void loadFile() {
      try {
        clearActors();
        clearParticles();
        File input = filePrompt(false);
        // return if there was no input file selected
        if (input == null) return;
        
        BufferedReader br = new BufferedReader(new FileReader(input));
        String line;
        while((line = br.readLine()) != null) {
        if(line.equals("SPD")) {
          MAX_SPEED = Float.parseFloat(br.readLine());
        } else if(line.equals("ROT")) {
           float x = Float.parseFloat(br.readLine());
           float y = Float.parseFloat(br.readLine());
           float m = Float.parseFloat(br.readLine());
           addActor(new Rotator(new PVector(x,y),m));
         } else if(line.equals("ATT")) {
           float x = Float.parseFloat(br.readLine());
           float y = Float.parseFloat(br.readLine());
           float m = Float.parseFloat(br.readLine());
           addActor(new Attractor(new PVector(x,y),m));
         } else if(line.equals("PAR")) {
           float lx = Float.parseFloat(br.readLine());
           float ly = Float.parseFloat(br.readLine());
           float vx = Float.parseFloat(br.readLine());
           float vy = Float.parseFloat(br.readLine());
           addParticle(new Particle(new PVector(lx,ly),new PVector(vx,vy),new PVector(0,0)));
         } else {
           System.out.println("Unable to load file, formatting error."); 
         }
        }
        br.close();
      } catch(IOException e) {
        e.printStackTrace();
      }
   
  }
  
  /**
   * Prompts with a FileChooser and returns the chosen File object or null.
   *
   * @param isSave true if this is a save prompt, false otherwise.
   * @return the File object representing the chosen file or null if cancelled.
   */
  public File filePrompt(boolean isSave) {
    JFrame f = new JFrame();
    f.setDefaultCloseOperation(f.EXIT_ON_CLOSE);
    
    JFileChooser fc = new JFileChooser();
    if (isSave) {
      fc.setDialogTitle("Save");
    }
    
    fc.showOpenDialog(f);
    return fc.getSelectedFile();
  }
}

public abstract class PhysicsActor {
  color m_color;
  PVector m_location;
  
  // reverses the effect if < 0
  float m_mass;
  
  // Constructor
  public PhysicsActor( PVector l, float m ) {
    m_location = l;
    m_mass = m;
  }
  
  // Modifies the path and momentum of the particle
  public abstract void actOn(Particle p);
  
  // Returns the object as as string
  public abstract String asString();
  
  // Draws the actor
  public void drawSelf() {
    stroke(m_color);
    fill(m_color);
    ellipse(m_location.x,m_location.y,10,10);
  }
}

/*class VortexPhysicsActor extends PhysicsActor {
  public void actOn(Particle p) {
  }
}*/
  

// Class which represents rotators, which act on particles.
// Rotators can have polarity 1 (counterclockwise) or -1 (clockwise)
class Rotator extends PhysicsActor {
  Rotator(PVector l, float m) {
    super(l, m);
  }
  
  void actOn(Particle p) {
    float magnitude = pow(abs(m_mass),1.2)/sqrt(pow(m_location.x - p.location.x,2)
      + pow(m_location.y - p.location.y,2));
      
      
    PVector direction = PVector.sub(p.location,m_location);
    
    float t;
    if(m_mass >= 0) {
      m_color = color(255,0,255);
      t = -(direction.y);
      direction.y = direction.x;
      direction.x = t;
    } else {
      m_color = color(180,0,180);
      t = -(direction.x);
      direction.x = direction.y;
      direction.y = t;
    }
    
    direction.normalize();
    direction.mult(magnitude);
    p.acceleration.add(direction);
  }
  
  String asString() {
    String myself = "ROT\n";
    myself += m_location.x + "\n";
    myself += m_location.y + "\n";
    myself += m_mass + "\n";
    return myself;
  }
}

// Class which represents attractors, which act on particles.  
// Attractors can have polarity 1 (attractive), or -1 (repulsive)
class Attractor extends PhysicsActor {
  Attractor(PVector l, float m) {
    super(l, m);
  }
  
  void actOn(Particle p) {
    float magnitude = abs(m_mass)/sqrt(pow(m_location.x - p.location.x,2)
      + pow(m_location.y - p.location.y,2));
      
    PVector direction = new PVector(0,0);
    
    if (m_mass >= 0) {
      m_color = color(250,180,0);
      direction = PVector.sub(m_location,p.location);
    } else {
      m_color = color(255,255,0);
      direction = PVector.sub(p.location,m_location);
    }
    
    direction.normalize();
    direction.mult(magnitude);
    p.acceleration.add(direction);
  }
  
  String asString() {
    String myself = "ATT\n";
    myself += m_location.x + "\n";
    myself += m_location.y + "\n";
    myself += m_mass + "\n";
    return myself;
  }
}

// Class which represents particles
class Particle {
  PVector location;      //The location of the particle
  PVector velocity;      //The velocity of the particle
  PVector acceleration;  //The acceleration of the particle
  
  Particle(PVector l, PVector v, PVector a) {
    location = l;
    velocity = v;
    acceleration = a;
  }
  
  Particle(PVector l) {
    this(l, new PVector(random(-2,2),random(-2,2)), new PVector(0,0));
  }
  
  void update() {
     velocity.add(acceleration);
     velocity.limit(MAX_SPEED);
     location.add(velocity);
     checkEdges();
     drawSelf();
     acceleration = new PVector(0,0);
  }
  
  void drawSelf() {
    stroke(0,0,0,255);
    fill(0,0,0,255);
    ellipse(location.x,location.y,PSIZE,PSIZE);
  }
  
  void checkEdges() {
    if(EDGE_MODE.equals("wrap")) {
      while (location.x > width)
        location.x -= width;
      while (location.x < 0)
        location.x += width;
   
    while (location.y > height)
      location.y -= height;
    while (location.y < 0)
      location.y += height;
      
    } else if(EDGE_MODE.equals("bounce")) {
      if(location.x > width || location.x < 0) {
        velocity = new PVector(-velocity.x,velocity.y);
      } 
      if(location.y > height || location.y < 0) {
        velocity = new PVector(velocity.x,-velocity.y);
      }
    }
  }
  
  String asString() {
    String myself = "PAR\n";
    myself += location.x + "\n";
    myself += location.y + "\n";
    myself += velocity.x + "\n";
    myself += velocity.y + "\n";
    return myself;
  }
}
