import processing.serial.*;

Serial myPort;        // Oggetto per la comunicazione seriale
float[] values;       // Array per memorizzare i valori
int index = 0;        // Indice per l'array
boolean firstContact = false; // Flag per il primo contatto con Arduino

void setup() {
  size(800, 400);
  
  // Inizializza l'array con 100 valori (tutti a 0 inizialmente)
  values = new float[100];
  for (int i = 0; i < values.length; i++) {
    values[i] = 0;
  }
  
  // Elenca le porte seriali disponibili
  printArray(Serial.list());
  
  // Apri la porta seriale (cambia 0 con l'indice corretto della tua porta)
  myPort = new Serial(this, Serial.list()[0], 9600);
  
  // Aspetta di ricevere il primo carattere da Arduino
  myPort.bufferUntil('\n');
}

void draw() {
  background(0);
  
  // Disegna il grafico
  stroke(255);
  noFill();
  beginShape();
  for (int i = 0; i < values.length; i++) {
    // Mappa l'indice alla larghezza della finestra e il valore all'altezza
    float x = map(i, 0, values.length-1, 0, width);
    float y = map(values[i], 0, 1023, height, 0); // Assumendo valori da 0 a 1023
    vertex(x, y);
  }
  endShape();
  
  // Mostra l'ultimo valore ricevuto
  fill(255);
  text("Ultimo valore: " + values[(index-1+values.length)%values.length], 20, 30);
}

void serialEvent(Serial myPort) {
  try {
    // Leggi la stringa fino al carattere di newline
    String inString = myPort.readStringUntil('\n');
    
    if (inString != null) {
      // Rimuovi spazi bianchi e caratteri non necessari
      inString = trim(inString);
      
      // Se è il primo contatto, invia un byte per sincronizzazione
      if (!firstContact) {
        if (inString.equals("Hello")) { // Arduino invia "Hello" all'inizio
          myPort.clear();               // Pulisci il buffer
          firstContact = true;          // Primo contatto stabilito
          myPort.write('A');           // Invia un byte per conferma
          println("Contatto stabilito");
        }
      } 
      else {
        // Converti la stringa in un numero float
        float inVal = float(inString);
        
        // Memorizza il valore nell'array
        values[index] = inVal;
        
        // Incrementa l'indice e torna a 0 se supera la lunghezza dell'array
        index = (index + 1) % values.length;
      }
    }
  }
  catch (Exception e) {
    println("Errore nella lettura seriale:");
    e.printStackTrace();
  }
}
