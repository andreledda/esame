import java.util.*;

class Waypoint {
  float lat, lon;
  String nome;
  
  Waypoint(float lat, float lon, String nome) {
    this.lat = lat;
    this.lon = lon;
    this.nome = nome;
  }
}

// Variabili globali
ArrayList<Waypoint> waypoints = new ArrayList<Waypoint>();
PImage mappa, barca;
float zoom = 1.0;
float offsetX = 0, offsetY = 0;
boolean dragging = false;
float dragX, dragY;
float bussolaAngle = 0;
float velocita = 0;
float direzione = 0;
float latitudine = 43.615;  // Posizione iniziale
float longitudine = 10.395;
long lastUpdate = 0;
int waypointSelezionato = -1;
boolean mostraRotta = true;

void setup() {
  size(1200, 800);
  smooth();
  
  // Carica immagini
  mappa = loadImage("mappa.png");
  barca = loadImage("barca.png");
  
  // Se le immagini non ci sono, crea delle alternative
  if (mappa == null) {
    mappa = createImage(2000, 2000, RGB);
    for (int i = 0; i < mappa.pixels.length; i++) {
      int x = i % mappa.width;
      int y = i / mappa.width;
      if ((x/100 + y/100) % 2 == 0) {
        mappa.pixels[i] = color(100, 150, 200);
      } else {
        mappa.pixels[i] = color(50, 100, 150);
      }
    }
    for (int x = 0; x < mappa.width; x++) {
      int y = 500 + (int)(100 * sin(x/200.0));
      if (y >= 0 && y < mappa.height) {
        mappa.pixels[y * mappa.width + x] = color(200, 180, 100);
      }
    }
  }
  
  if (barca == null) {
    barca = createImage(40, 40, ARGB);
    barca.loadPixels();
    for (int i = 0; i < barca.pixels.length; i++) {
      barca.pixels[i] = color(0, 0);
    }
    // Disegna una semplice barca triangolare
    for (int y = 0; y < 40; y++) {
      for (int x = 0; x < 40; x++) {
        if (abs(x-20) < y/2 && y < 30) {
          barca.pixels[y*40 + x] = color(200, 100, 50);
        }
      }
    }
    barca.updatePixels();
  }
  
  // Aggiungi waypoint di esempio
  waypoints.add(new Waypoint(43.615, 10.395, "Partenza"));
  waypoints.add(new Waypoint(43.625, 10.405, "Waypoint 1"));
  waypoints.add(new Waypoint(43.635, 10.415, "Arrivo"));
}

void draw() {
  background(0);
  
  // Disegna la mappa
  pushMatrix();
  translate(width/2, height/2);
  scale(zoom);
  imageMode(CENTER);
  image(mappa, offsetX, offsetY);
  
  // Disegna la rotta
  if (mostraRotta && waypoints.size() > 1) {
    stroke(0, 255, 255, 150);
    strokeWeight(3/zoom);
    noFill();
    beginShape();
    for (Waypoint wp : waypoints) {
      float x = lonToX(wp.lon) + offsetX;
      float y = latToY(wp.lat) + offsetY;
      vertex(x, y);
    }
    endShape();
  }
  
  // Disegna i waypoint
  for (int i = 0; i < waypoints.size(); i++) {
    Waypoint wp = waypoints.get(i);
    float x = lonToX(wp.lon) + offsetX;
    float y = latToY(wp.lat) + offsetY;
    
    // Cerchio waypoint
    fill(i == waypointSelezionato ? color(255, 255, 0) : color(255, 0, 0));
    ellipse(x, y, 15/zoom, 15/zoom);
    
    // Nome waypoint
    if (zoom > 0.5) {
      fill(255);
      textSize(12/zoom);
      textAlign(CENTER);
      text(wp.nome, x, y + 20/zoom);
    }
  }
  
  // Disegna la barca
  pushMatrix();
  float boatX = lonToX(longitudine) + offsetX;
  float boatY = latToY(latitudine) + offsetY;
  translate(boatX, boatY);
  rotate(radians(bussolaAngle + 90));
  imageMode(CENTER);
  image(barca, 0, 0, 40/zoom, 40/zoom);
  popMatrix();
  
  popMatrix();
  
  // Pannelli UI
  drawDataPanel();
  drawCompass();
  
  // Aggiorna posizione barca
  updatePosition();
}

float lonToX(float lon) {
  return map(lon, longitudine-0.1, longitudine+0.1, -500, 500);
}

float latToY(float lat) {
  return map(lat, latitudine-0.1, latitudine+0.1, -500, 500);
}

void drawDataPanel() {
  fill(50, 200);
  rect(width - 300, 0, 300, height);
  
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("GPS Nautico", width - 280, 20);
  
  textSize(16);
  text("Lat: " + nf(latitudine, 0, 5) + "°", width - 280, 60);
  text("Lon: " + nf(longitudine, 0, 5) + "°", width - 280, 90);
  text("Velocità: " + nf(velocita, 0, 1) + " nodi", width - 280, 120);
  text("Direzione: " + nf(direzione, 0, 0) + "°", width - 280, 150);
  text("Waypoints: " + waypoints.size(), width - 280, 180);
  
  // Pulsanti
  fill(0, 100, 200);
  rect(width - 280, height - 160, 240, 40, 5);
  fill(255);
  text("Aggiungi Waypoint", width - 270, height - 150);
  
  fill(mostraRotta ? color(0, 150, 0) : color(100, 0, 0));
  rect(width - 280, height - 110, 240, 40, 5);
  fill(255);
  text(mostraRotta ? "Nascondi Rotta" : "Mostra Rotta", width - 270, height - 100);
  
  fill(200, 0, 0);
  rect(width - 280, height - 60, 240, 40, 5);
  fill(255);
  text("Cancella Tutto", width - 270, height - 50);
}

void updatePosition() {
  if (waypoints.size() > 0 && frameCount % 2 == 0) {
    // Muovi verso il waypoint corrente
    Waypoint target = waypoints.get(0);
    float dx = target.lon - longitudine;
    float dy = target.lat - latitudine;
    float dist = sqrt(dx*dx + dy*dy);
    
    if (dist < 0.001) { // Se raggiunto
      if (waypoints.size() > 1) {
        waypoints.remove(0); // Passa al prossimo waypoint
      }
    } else {
      // Muovi verso il waypoint
      float speed = 0.0001;
      longitudine += dx * speed;
      latitudine += dy * speed;
      direzione = degrees(atan2(dy, dx));
      bussolaAngle = direzione;
      velocita = dist * 10000;
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    if (mouseX < width - 300) {
      // Controlla se clic su un waypoint
      waypointSelezionato = -1;
      for (int i = 0; i < waypoints.size(); i++) {
        Waypoint wp = waypoints.get(i);
        float x = width/2 + (lonToX(wp.lon) + offsetX) * zoom;
        float y = height/2 + (latToY(wp.lat) + offsetY) * zoom;
        if (dist(mouseX, mouseY, x, y) < 15) {
          waypointSelezionato = i;
          break;
        }
      }
      
      if (waypointSelezionato == -1) {
        dragging = true;
        dragX = mouseX;
        dragY = mouseY;
      }
    }
  }
}

void mouseDragged() {
  if (dragging) {
    offsetX += (mouseX - dragX) / zoom;
    offsetY += (mouseY - dragY) / zoom;
    dragX = mouseX;
    dragY = mouseY;
  } else if (waypointSelezionato >= 0) {
    // Sposta waypoint
    Waypoint wp = waypoints.get(waypointSelezionato);
    wp.lon = map(mouseX - width/2 - offsetX*zoom, -500*zoom, 500*zoom, longitudine-0.1, longitudine+0.1);
    wp.lat = map(mouseY - height/2 - offsetY*zoom, -500*zoom, 500*zoom, latitudine-0.1, latitudine+0.1);
  }
}

void mouseReleased() {
  dragging = false;
  waypointSelezionato = -1;
}

void mouseClicked() {
  if (mouseX > width - 280 && mouseX < width - 40) {
    if (mouseY > height - 160 && mouseY < height - 120) {
      // Aggiungi waypoint
      String nome = "WP " + (waypoints.size()+1);
      waypoints.add(new Waypoint(latitudine, longitudine, nome));
    } else if (mouseY > height - 110 && mouseY < height - 70) {
      // Mostra/nascondi rotta
      mostraRotta = !mostraRotta;
    } else if (mouseY > height - 60 && mouseY < height - 20) {
      // Cancella tutto
      waypoints.clear();
    }
  } else if (mouseButton == RIGHT && mouseX < width - 300) {
    // Aggiungi waypoint nella posizione cliccata
    float lon = map(mouseX - width/2 - offsetX*zoom, -500*zoom, 500*zoom, longitudine-0.1, longitudine+0.1);
    float lat = map(mouseY - height/2 - offsetY*zoom, -500*zoom, 500*zoom, latitudine-0.1, latitudine+0.1);
    String nome = "WP " + (waypoints.size()+1);
    waypoints.add(new Waypoint(lat, lon, nome));
  }
}

void drawCompass() {
  // Cerchio esterno della bussola
  fill(40, 150);
  stroke(100);
  strokeWeight(2);
  ellipse(100, 100, 150, 150);
  
  // Disegna la rosa dei venti
  pushMatrix();
  translate(100, 100);
  
  // Linea direzione nord
  rotate(radians(bussolaAngle));
  stroke(255, 0, 0);
  strokeWeight(3);
  line(0, 0, 0, -60);
  
  // Triangolo indicatore nord
  fill(255, 0, 0);
  noStroke();
  triangle(-5, -60, 5, -60, 0, -75);
  
  // Cerchio centrale
  fill(50);
  ellipse(0, 0, 20, 20);
  
  popMatrix();
  
  // Punti cardinali
  fill(255);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("N", 100, 35);
  text("E", 155, 100);
  text("S", 100, 165);
  text("W", 45, 100);
  
  // Indicatore angolo
  fill(50);
  rect(70, 180, 60, 25, 5);
  fill(255);
  text(nf(bussolaAngle, 0, 0)+"°", 100, 193);
}


void keyPressed() {
  if (key == '+' || key == '=') {
    zoom *= 1.1;
  } else if (key == '-' || key == '_') {
    zoom /= 1.1;
  } else if (key == ' ') {
    // Barra spaziatrice per mettere in pausa il movimento
    waypoints.add(0, new Waypoint(latitudine, longitudine, "Pausa"));
  }
}
