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
   
  // Linee orizzontali
  for (int i = 0; i < 10; i++) {
    
    float y = map(i, 0, 9, height - 50, 50);                 // Calcola l'area dove disegnare le righe vreticali (da 50px dal fondo a 50px dall'alto)
    line(50, y, width - 50, y);                              // Disegna le linea
  }
  
  
}

void draw() {
  background(0);
  
}
