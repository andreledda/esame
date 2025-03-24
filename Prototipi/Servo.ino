#include <Servo.h>

Servo myservo;  // definisci il servo


int pos = 0;    // posizione servo

void setup() {
  myservo.attach(9);  // pin di connessione allla scheda
}

void loop() {
  for (pos = 0; pos <= 180; pos += 1) { // imposta pos a 0, poi aumentalo unità per unità. Dopo ogni aumento, esegui il codice nel ciclo fino a quando pos arriva a 180
    myservo.write(pos);              // sposta il servo alla posizione pos
    delay(15);                       // tempo per far muovere il servo
  }
  for (pos = 180; pos >= 0; pos -= 1) { // imposta pos a 0, poi aumentalo unità per unità. Dopo ogni aumento, esegui il codice nel ciclo fino a quando pos arriva a 180
    myservo.write(pos);              // sposta il servo alla posizione pos
    delay(15);                       // tempo per far muovere il servo
  }
}
