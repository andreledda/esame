#include <Servo.h>

// variabili servo
Servo myservo;  // definisci il servo
int pos = 0;    // posizione servo

// variabili sensore ultrasuoni
const int trigPin = 12; 
const int echoPin = 13;
float duration;
float distance;


int misuraDistanza() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(4);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH, 30000); // Timeout 30ms
  
  if (duration <= 0) {
    Serial.print(pos);
    Serial.print(",ERRORE."); // Marcatore di errore (il tempo di ritorno non pouo essere pari o minore di 0)
  } else {
    distance = (duration * 0.0343) / 2;
    Serial.print(pos);
    Serial.print(",");
    Serial.print(distance, 0); // rendi la misura un intero per facilitare la lettura da parte di processing
    Serial.print(".");
  }
  delay(50); 
}

void setup() {
  myservo.attach(9);  // pin di connessione alla scheda del servo
  Serial.begin(9600);
  myservo.write(15); // direzione di start per il servo
  pinMode(trigPin, OUTPUT); 
  pinMode(echoPin, INPUT);  
}

void loop() {
  for (pos = 15; pos <= 165; pos += 1) { // imposta pos a 0, poi aumentalo unità per unità. Dopo ogni aumento, esegui il codice nel ciclo fino a quando pos arriva a 180
    myservo.write(pos);              // sposta il servo alla posizione pos
    delay(15);                       // tempo per far muovere il servo
    misuraDistanza();
  }
  for (pos = 165; pos >= 15; pos -= 1) { // imposta pos a 0, poi aumentalo unità per unità. Dopo ogni aumento, esegui il codice nel ciclo fino a quando pos arriva a 0
    myservo.write(pos);              // sposta il servo alla posizione pos
    delay(15);                       // tempo per far muovere il servo
    misuraDistanza();
  }
}
