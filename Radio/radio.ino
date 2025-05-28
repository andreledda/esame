#include <LiquidCrystal.h>

// Definizione pin
const int distress = 10;
const int up = 7;
const int down = 9;
const int select = 8;
const int buzzer = 6;

// Variabili stato radio
int channel = 16;
bool squelch = true;
unsigned long distressStartTime = 0;
bool distressMode = false;
bool selectingEmergency = false;
int emergencyType = 0;
bool buzzerActive = false;
unsigned long lastBuzzerToggle = 0;
bool debounceSelezione = false; 

const char* emergencyTypes[] = {
  "AFFONDAMENTO ",
  "INCENDIO     ",
  "EMER. MEDICA ",
  "PIRATERIA    "
};

// Inizializza LCD (RS, E, D4, D5, D6, D7)
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
  pinMode(up, INPUT_PULLUP);
  pinMode(down, INPUT_PULLUP);
  pinMode(select, INPUT_PULLUP);
  pinMode(distress, INPUT_PULLUP);
  pinMode(buzzer, OUTPUT);
  
  lcd.begin(16, 2);
  home();
}

void loop() {
  static unsigned long lastDebounceTime = 0;
  
  // Gestione distress button (edge detection)
  if (digitalRead(distress) == LOW && !distressMode && !selectingEmergency) {
    distressStartTime = millis();
    distressMode = true;
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("DISTRESS");
    lcd.setCursor(0, 1);
    lcd.print("TENERE X 5 SEC");
  }

  // Gestione modalità distress
  if (distressMode) {
    // Buzzer intermittente
    if (millis() - lastBuzzerToggle > 500) {
      lastBuzzerToggle = millis();
      buzzerActive = !buzzerActive;
      if (buzzerActive) {
        tone(buzzer, 1000);
      } else {
        noTone(buzzer);
      }
    }

    // Controllo se è ancora premuto
    if (digitalRead(distress) == HIGH) {
      // Rilasciato prima del tempo
      distressMode = false;
      noTone(buzzer);
      home();
    } 
    else if (millis() - distressStartTime >= 5000) {
      // Tenuto premuto per 5 secondi
      distressMode = false;
      selectingEmergency = true;
      noTone(buzzer);
      tone(buzzer, 1500); // Suono continuo

      for (int i = 1; i<=3; i++){
        tone(buzzer, 1500);
        delay(50);
        noTone(buzzer);
        delay(50);
      }
      showEmergencySelection();
    }
    return;
  }

  // Gestione selezione emergenza
  if (selectingEmergency) {
    handleEmergencySelection();
    return;
  }

  // Operazioni normali
  if (millis() - lastDebounceTime > 200) {
    if (digitalRead(up) == LOW) {
      channel = min(channel + 1, 16);
      home();
      lastDebounceTime = millis();
      while (digitalRead(up) == LOW);
    }
    else if (digitalRead(down) == LOW) {
      channel = max(channel - 1, 1);
      home();
      lastDebounceTime = millis();
      while (digitalRead(down) == LOW);
    }
    else if (digitalRead(select) == LOW) {
      squelch = !squelch;
      home();
      lastDebounceTime = millis();
      while (digitalRead(select) == LOW);
    }
  }
}

void showEmergencySelection() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("SELEZ. EMERGENZA");
  updateEmergencyDisplay();
}

void handleEmergencySelection() {
  static unsigned long lastEmergencyDebounce = 0;
  if (!debounceSelezione){
    delay(1500);
    debounceSelezione = true;
  }
  if (millis() - lastEmergencyDebounce > 200) {
    if (digitalRead(up) == LOW) {
      emergencyType = (emergencyType + 1) % 4;
      updateEmergencyDisplay();
      lastEmergencyDebounce = millis();
      while (digitalRead(up) == LOW);
    }
    else if (digitalRead(down) == LOW) {
      emergencyType = (emergencyType - 1 + 4) % 4;
      updateEmergencyDisplay();
      lastEmergencyDebounce = millis();
      while (digitalRead(down) == LOW);
    }
    else if (digitalRead(select) == LOW) {
      sendDistress();
      lastEmergencyDebounce = millis();
      while (digitalRead(select) == LOW);
    }
    else if (digitalRead(distress) == LOW) {
      selectingEmergency = false;
      noTone(buzzer);
      home();
      while (digitalRead(distress) == LOW);
    }
  }
}

void updateEmergencyDisplay() {
  lcd.setCursor(0, 1);
  lcd.print("<");
  lcd.setCursor(2, 1);
  lcd.print(emergencyTypes[emergencyType]);
  lcd.setCursor(15, 1);
  lcd.print(">");
}

void sendDistress() {
  selectingEmergency = false;
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("INVIO DISTRESS");
  lcd.setCursor(0, 1);
  lcd.print("TIPO: ");
  lcd.print(emergencyTypes[emergencyType]);
  debounceSelezione = false;
  
  // Suono di conferma
  for (int i = 0; i < 3; i++) {
    tone(buzzer, 2000);
    delay(300);
    noTone(buzzer);
    delay(200);
  }
  
  if(select == LOW){
    delay(300);
    home();
  }
  
}

void home() {   // Schermata di base
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("CH ");
  lcd.print(channel);
  lcd.setCursor(8, 0);
  lcd.print("SQL ");
  lcd.print(squelch ? "ON " : "OFF");
  lcd.setCursor(0, 1);
  lcd.print("VHF EMERG SIM");
}
