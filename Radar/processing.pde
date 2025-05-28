import processing.serial.*;

Serial myPort;
String angle = "", distance = "";
int iAngle = 0, iDistance = 0;
boolean connected = false;
ArrayList<PVector> objectHistory = new ArrayList<PVector>();

void setup() {
  size(1280, 720);
  smooth();
  textSize(16);
  
  // INSERISCI MANUALMENTE LA PORTA CORRETTA QUI SOSTITUENDO "COM5"
  try {
    myPort = new Serial(this, "COM6", 9600); // <-- MODIFICA QUESTA RIGA
    myPort.bufferUntil('.');
    connected = true;
    println("Connessione riuscita a: COM5"); // <-- MODIFICA ANCHE QUESTA RIGA
  } catch (Exception e) {
    println("Errore di connessione: " + e.getMessage());
    connected = false;
  }
}

void draw() {
  if (!connected) {
    background(0);
    fill(255, 0, 0);
    text("DISCONNESSO - Verificare la connessione seriale", width/2 - 200, height/2);
    return;
  }
  
  // Sfondo con effetto fade leggero
  noStroke();
  fill(0, 15); 
  rect(0, 0, width, height);
  
  // Disegno elementi radar
  drawRadar();
  drawHistory(); // Disegna la traccia storica
  drawLine();
  drawObject();
  drawText();
  
  // Debug overlay
  fill(255);
  text("Angolo: " + iAngle + "° - Distanza: " + iDistance + "cm", 20, 30);
}

void serialEvent(Serial port) {
  try {
    String rawData = port.readStringUntil('.').trim();
    
    if (rawData == null || rawData.isEmpty()) return;
    
    // Parsing dati
    String[] parts = splitTokens(rawData, ",");
    if (parts.length == 2) {
      angle = parts[0].trim();
      distance = parts[1].replace(".", "").trim();
      
      try {
        iAngle = constrain(int(angle), 0, 180);
        iDistance = int(distance);
        if (iDistance > 0 && iDistance < 500) { // Filtra valori non validi
          // Aggiungi alla storia in modo sicuro
          float x = width/2 + cos(radians(iAngle)) * iDistance * 2;
          float y = height - 100 - sin(radians(iAngle)) * iDistance * 2;
          synchronized(objectHistory) {
            objectHistory.add(new PVector(x, y));
            if (objectHistory.size() > 100) {
              objectHistory.remove(0);
            }
          }
        }
      } catch (NumberFormatException e) {
        println("Formato non valido: " + rawData);
      }
    }
  } catch (Exception e) {
    println("Errore: " + e.getMessage());
  }
}

void drawRadar() {
  pushMatrix();
  translate(width/2, height - 100);
  
  // Cerchi concentrici (40cm, 80cm, 120cm)
  noFill();
  stroke(98, 245, 31, 150);
  strokeWeight(1);
  for (int r = 1; r <= 3; r++) {
    arc(0, 0, r*200, r*200, PI, TWO_PI);
  }
  
  // Linee angolari (30° steps)
  for (int a = 0; a <= 180; a += 30) {
    float x = -350 * cos(radians(a));
    float y = -350 * sin(radians(a));
    stroke(98, 245, 31, 100);
    line(0, 0, x, y);
  }
  popMatrix();
}

void drawHistory() {
  // Disegna tutti i punti storici in modo sicuro
  synchronized(objectHistory) {
    noStroke();
    for (PVector p : objectHistory) {
      float alpha = map(p.dist(new PVector(width/2, height-100)), 0, 400, 255, 50);
      fill(255, 100, 100, alpha);
      ellipse(p.x, p.y, 5, 5);
    }
  }
}

void drawLine() {
  pushMatrix();
  translate(width/2, height - 100);
  stroke(30, 250, 60);
  strokeWeight(2);
  line(0, 0, 200 * cos(radians(iAngle)), -200 * sin(radians(iAngle)));
  popMatrix();
}

void drawObject() {
  if (iDistance <= 0 || iDistance > 400) return;
  
  pushMatrix();
  translate(width/2, height - 100);
  
  // Calcolo posizione oggetto
  float objSize = map(iDistance, 0, 400, 15, 5);
  float objX = iDistance * 0.5 * cos(radians(iAngle));
  float objY = -iDistance * 0.5 * sin(radians(iAngle));
  
  // Disegno oggetto
  fill(255, 0, 0);
  noStroke();
  ellipse(objX, objY, objSize, objSize);
  popMatrix();
}

void drawText() {
  // Scala distanze
  fill(98, 245, 31);
  textSize(14);
  text("100cm", width/2 - 100, height - 80);
  text("200cm", width/2 - 200, height - 80);
  text("0cm", width/2, height - 80);
  text("100cm", width/2 + 100, height - 80);
  text("200cm", width/2 + 200, height - 80);
  
  // Indicatori angolo
  text("0°", width/2 - 220, height - 100);
  text("180°", width/2 + 200, height - 100);
  text("90°", width/2, height - 250);
}

void keyPressed() {
  if (key == 'c') {
    synchronized(objectHistory) {
      objectHistory.clear(); // Pulisce la traccia con il tasto 'c'
    }
  }
}
