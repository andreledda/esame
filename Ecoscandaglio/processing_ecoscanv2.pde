import processing.serial.*;

Serial myPort;       // Oggetto per la comunicazione seriale
float[] values;      // Array (tipo lista python) per memorizzare i valori
int index = 0;       // Indice per la posizione di lettura nell'array

void setup() {
  size(1280, 720);    
  
  // Inizializzazione array
  values = new float[100];                                  // crea 100 valori
  for (int i = 0; i < values.length; i++) {                 // scorri tuti i valori
    values[i] = 0;                                          // Inizializza tutti i valori a 0
  }
  
  myPort = new Serial(this, Serial.list()[0], 9600);        // Avvia la seriale (COM6)
  
  
  myPort.bufferUntil('\n');                                 // Leggi i dati fino al carattere di nuova linea (uguale a python XD)
}

void serialEvent(Serial myPort) {                           // Serie di istruzioni per leggere la seriale
  try {
    
    String inString = myPort.readStringUntil('\n');         // Leggi la stringa dalla porta seriale
    
    if (inString != null) {                                 // Se la stringa contiene dei dati (! è come il not in python) 
      inString = trim(inString);                            // Rimuovi spazi bianchi e converti in float
      float inValue = float(inString);                      // crea il valore 
      values[index] = inValue;                              // Aggiungi il valore all'array
      
      index = (index + 1) % values.length;                  // Aggiungi 1 all'indice in modo che il prossimo dato venga memorizzato nel prossimo slot. Se arrivi a 100 riparti da 0 
    }
  }
  catch (Exception e) {                                     // Se i dati sono corrotti esci dal ciclo
    println("Errore nella lettura dei dati seriali:");
    e.printStackTrace();
  }
}

void disegnaGriglia() {
  stroke(200);                                               // grigio
  strokeWeight(1);                                           // spessore in px
   
// Linee orizzontali ogni 50 unità (0, 50, 100, 150, 200, 250)
  for (int yValue = 250; yValue >= 0; yValue -= 50) {
  float y = map(yValue, 0, 250, 50, height - 50);
    line(50, y, width - 50, y);  // Disegna la linea
    
    // Opzionale: aggiungi etichette testuali
    fill(100);
    textAlign(RIGHT, CENTER);
    text(yValue, 45, y);  // Mostra il valore (es. "50") a sinistra della linea
  }
  
  
}

void lineaGrafico() {
  stroke(243, 255, 166);                                     // Colore per la linea
  strokeWeight(2);                                           // Spessore linea (2px)
  noFill();
  beginShape();
  for (int i = 0; i < values.length; i++) {
    
    float x = map(i, 0, values.length - 1, 50, width - 50);
    
    // Mappa il valore nell'intervallo di visualizzazione
    float y = map(values[i], 0, 250, 50, height - 50);       // impostazione del range di valori (0 - 250)  
    vertex(x, y);
  }
  endShape();
}


void draw() {
  background(0);
  disegnaGriglia();
  lineaGrafico();
  fill(255);
  textAlign(RIGHT, CENTER);
  text("Profondità attuale: " + values[(index - 1 + values.length) % values.length], width - 20, 30);  // Mostra il valore corrente
}
