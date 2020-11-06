final double display_width = 1000;
final double display_height = 1000;
final double min_new_particle_offset = 0.1;
final double max_new_particle_offset = 0.3;
final double oddball_chance = 0.3;

ArrayList<Particle> particles;
double time_until_new_particle;

class Vector2D {
  double x;
  double y;
  
  Vector2D(double i_x, double i_y) {
    x = i_x;
    y = i_y;
  }
  
  Vector2D plus(Vector2D other) {
    return new Vector2D(
      x + other.x,
      y + other.y
    );
  }
  
  Vector2D minus(Vector2D other) {
    return new Vector2D(
      x - other.x,
      y - other.y
    );
  }
  
  Vector2D multiply(double other) {
    return new Vector2D(
      x * other,
      y * other
    );
  }
  
  Vector2D divide(double other) {
    return new Vector2D(
      x / other,
      y / other
    );
  }
  
  double magnitude_sq() {
    return x * x + y * y;
  }
  
  double magnitude() {
    return Math.sqrt(magnitude_sq());
  }
}

double get_random_double(double bottom, double top) {
  return bottom + Math.random() * (top - bottom);
}

color get_random_color() {
  return color(
    (int)get_random_double(0, 256),
    (int)get_random_double(0, 256),
    (int)get_random_double(0, 256)
  );
}

Vector2D get_random_border_pos(double radius) {
  double expanded_width = display_width + 2 * radius;
  double expanded_height = display_height + 2 * radius;
  
  int choice = (int)get_random_double(0, 4);
  double x = 0;
  double y = 0;
  switch (choice) {
    case 0:
      x = -expanded_width / 2;
      y = get_random_double(
        -expanded_height / 2,
        expanded_height / 2
      );
      break;
    case 1:
      y = expanded_height / 2;
      x = get_random_double(
        -expanded_width / 2,
        expanded_width / 2
      );
      break;
    case 2:
      x = expanded_width / 2;
      y = get_random_double(
        -expanded_height / 2,
        expanded_height / 2
      );
      break;
    case 3:
      y = -expanded_height / 2;
      x = get_random_double(
        -expanded_width / 2,
        expanded_width / 2
      );
      break;
  }
  return new Vector2D(x, y);
}

void setup() {
  size(1000, 1000);
  particles = new ArrayList<Particle>();
  time_until_new_particle = 0;
}

void draw() {
  background(color(0xff, 0xff, 0xff));
  translate(
    (float)(display_width / 2),
    (float)(display_height / 2)
  );
  
  double time_delta = 1.0 / frameRate; // time elapsed in seconds since last draw
  ArrayList<Integer> removal_indices = new ArrayList<Integer>();
  for (int i = 0; i < particles.size(); ++i) {
    Particle part = particles.get(i);
    part.show();
    part.move(time_delta);
    if (part.finished()) {
      removal_indices.add(i);
    }
  }
  
  int num_removed = 0;
  for (Integer i : removal_indices) {
    particles.remove(i - num_removed);
    ++num_removed;
  }
  
  time_until_new_particle -= time_delta;
  if (time_until_new_particle <= 0) {
    Particle new_particle;
    
    double radius = get_random_double(30, 90);
    
    Vector2D beginning_pos = get_random_border_pos(radius);
    
    if (Math.random() < oddball_chance) {
      new_particle = new OddballParticle(
        beginning_pos,
        radius,
        get_random_color(),
        new Vector2D(
          get_random_double(-90, 90),
          get_random_double(-90, 90)
        ),
        get_random_double(0, 2 * PI),
        get_random_double(-2 * PI, 2 * PI)
      );
    }
    else {
      new_particle = new Particle(
        beginning_pos,
        radius,
        get_random_color(),
        new Vector2D(
          get_random_double(-150, 150),
          get_random_double(-150, 150)
        )
      );
    }
    
    particles.add(new_particle);
    
    time_until_new_particle = get_random_double(
      min_new_particle_offset,
      max_new_particle_offset
    );
  }
}

class Particle {
  private Vector2D center;
  private double radius;
  private color particle_color;
  private Vector2D velocity;
  
  public Particle(
    Vector2D i_center,
    double i_radius,
    color i_particle_color,
    Vector2D i_velocity
  ) {
    center = i_center;
    radius = i_radius;
    particle_color = i_particle_color;
    velocity = i_velocity;
  }
  
  public Vector2D get_center() {
    return center;
  }
  
  public double get_radius() {
    return radius;
  }
  
  public color get_particle_color() {
    return particle_color;
  }
  
  public void move(double time_delta) {
    center = center.plus(velocity.multiply(time_delta));
  }
  
  public void show() {
    stroke(color(0xff, 0xff, 0xff));
    strokeWeight(1);
    fill(particle_color);
    ellipseMode(RADIUS);
    ellipse(
      (float)center.x,
      (float)center.y,
      (float)radius,
      (float)radius
    );
  }
  
  public boolean finished() {
    boolean check_x
      = (center.x + radius < -display_width / 2 && velocity.x < 0)
        || (center.x - radius > display_width / 2 && velocity.x > 0);
    boolean check_y
      = (center.y + radius < -display_height / 2 && velocity.y < 0)
        || (center.y - radius > display_height / 2 && velocity.y > 0);
    return check_x || check_y;
  }
}

class OddballParticle extends Particle {
  private double ang_displacement;
  private double ang_velocity;
  
  public OddballParticle(
    Vector2D i_center,
    double i_radius,
    color i_particle_color,
    Vector2D i_velocity,
    double i_ang_displacement,
    double i_ang_velocity
  ) {
    super(
      i_center,
      i_radius,
      i_particle_color,
      i_velocity
    );
    ang_displacement = i_ang_displacement;
    ang_velocity = i_ang_velocity;
  }
  
  void move(double time_delta) {
    super.move(time_delta);
    ang_displacement += ang_velocity * time_delta;
    ang_displacement %= 2 * PI;
  }
  
  void show() {
    double this_radius = get_radius() * 4/5;
    Vector2D this_center = get_center();
    
    stroke(color(0xff, 0xff, 0xff));
    strokeWeight(1);
    fill(get_particle_color());
    
    double distortion = sin((2 * PI / 1000) * millis());
    beginShape();
    for (double theta = 0; theta < 2 * PI; theta += (2 * PI) / 50) {
      double r
        = this_radius + (this_radius / 4) * distortion * Math.sin(4 * theta);
      double x = this_center.x + r * Math.cos(theta + ang_displacement);
      double y = this_center.y + r * Math.sin(theta + ang_displacement);
      vertex((float)x, (float)y);
    }
    endShape();
  }
}
