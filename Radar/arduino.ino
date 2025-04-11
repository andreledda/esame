#include <Servo.h>

// variabili servo
Servo myservo;  // definisci il servo
int pos = 0;    // posizione servo

// variabili sensore ultrasuoni
const int trigPin = 9; 
const int echoPin = 10;
float duration;
float distance;


int misuraDistanza() {
    digitalWrite(trigPin, LOW); // stringa di inizializzazione
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);	// impulso
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW); // fine impulso
    duration = pulseIn(echoPin, HIGH); // Misura per quanto tempo echoPin rimane HIGH, quindi durata del ritorno
    distance = (duration * 0.034) / 2;
    delay(100);
    Serial.print(pos);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(".");
}

void setup() {
  myservo.attach(9);  // pin di connessione alla scheda
  Serial.begin(9600);
  myservo.write(15);
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