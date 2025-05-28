
#include <LiquidCrystal.h>

const int startStopButton = 9;
const int resetButton = 3;
const int buzzer = 8; 
const int fungo = 10; // Ale

// Variabili timer
bool timerRunning = false;
unsigned long timerStartTime = 0; // punto da cui contare i millis x il timer
const unsigned long durataTimer = 300000; // 5 minuti (300000 ms)

// LCD
// Inizializza LCD (RS, E, D4, D5, D6, D7)
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

// Variabili suoni
bool hasSounded5 = false;             // conferme necessarie per continuare il programma
bool hasSounded4 = false;
bool hasSounded1 = false;
bool hasSoundedStart = false;

void setup() {
  pinMode(startStopButton, INPUT_PULLUP);
  pinMode(resetButton, INPUT_PULLUP);
  pinMode(buzzer, OUTPUT);
  Serial.begin(9600);
  Serial.println("Sistema pronto");
  lcd.begin(16, 2);
  lcd.setCursor(0,0);
  lcd.print("Sistema Pronto");
}

void loop() {
  // Gestione pulsanti
  

  if (digitalRead(startStopButton) == LOW) {
    delay(50); // Debounce 
    
    if (!timerRunning) {
      // Avvia timer
      timerRunning = true;
      timerStartTime = millis();
      resetSoundFlags();
      playSound(1500); // Suono all'avvio
      hasSoundedStart = true;
      Serial.println("Timer avviato - 5 minuti conto alla rovescia");
      lcd.clear();
      lcd.print("Timer avviato");
    } else {
      // Ferma timer
      timerRunning = false;
      Serial.println("Timer fermato");
    }
    while(digitalRead(startStopButton) == LOW); // Aspetta rilascio
  }

  if (digitalRead(resetButton) == LOW && !timerRunning) {
    delay(50);
    timerStartTime = 0;
    resetSoundFlags();
    Serial.println("Timer resettato");
    while(digitalRead(resetButton) == LOW);
  }

  // Gestione timer e suoni
  if (timerRunning) {
    unsigned long remaining = durataTimer - (millis() - timerStartTime);
    
    // Suoni ai vari intervalli
    if (remaining <= 300000 && !hasSounded5) { // 5 minuti (all'avvio)
      hasSounded5 = true;
    }
    if (remaining <= 240000 && !hasSounded4) { // 4 minuti
      playSound(1500);
      hasSounded4 = true;
    }
    if (remaining <= 60000 && !hasSounded1) { // 1 minuto
      playSound(1500);
      hasSounded1 = true;
    }
    if (remaining <= 0) { // Timer scaduto
      playSound(1500); // Singolo suono finale
      timerRunning = false;
      Serial.println("Race started");
      setup();
    }

    // Display tempo ogni secondo
    static unsigned long lastPrint = 0;
    if (millis() - lastPrint >= 1000) {
      lastPrint = millis();
      Serial.print("Tempo rimanente: ");
      Serial.print(remaining / 60000);
      Serial.print(":");
      if ((remaining % 60000) / 1000 < 10) Serial.print("0");
      Serial.println((remaining % 60000) / 1000);
      lcd.setCursor(0,1);
      lcd.print(remaining / 60000); // minuti mancanti
      lcd.print(":");
      lcd.print((remaining % 60000) / 1000); // secondi mancanti
    }
  }
}

void resetSoundFlags() {
  hasSounded5 = false;
  hasSounded4 = false;
  hasSounded1 = false;
  hasSoundedStart = false;
}

void playSound(int duration) {
  tone(buzzer, 1000, duration);
  delay(duration);
  noTone(buzzer);
}
