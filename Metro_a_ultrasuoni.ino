// C++ code
/* metro ad ultrasuoni
By Andrea 

Questo codice rileva la distanza di un oggetto con un sensore a ultrasuoni e la scrive sulla seriale e su un LCD. 
Credo che sia la base per radar e ecoscandaglio

CIRCUITO DEL SENSORE:
 * trig --> 9
 * echo --> 10

CIRCUITO DELL'LCD:
 * LCD RS --> pin 12
 * LCD Enable --> pin 11
 * LCD D4 --> pin 5
 * LCD D5 --> pin 4
 * LCD D6 --> pin 3
 * LCD D7 --> pin 2
 * LCD R/W --> GND
 * LCD VSS --> GND
 * LCD VCC --> 5V


*/


const int trigPin = 9;
const int echoPin = 10;

#include <LiquidCrystal.h>  // Libreria dell'LCD
const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

float duration; // tempo tra invio e ritorno del segnale
float distance; // distanza dell'oggetto

void setup()
{
  Serial.begin(9600);
  lcd.begin(16, 2);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  lcd.setCursor(1, 1);
  lcd.print("By Andrea");
}

void loop()
{
    digitalWrite(trigPin, LOW); // stringa di inizializzazione
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);	// impulso
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW); // fine impulso
    duration = pulseIn(echoPin, HIGH); // Misura per quanto tempo echoPin rimane HIGH, quindi durata del ritorno
    distance = (duration * 0.034) / 2;
  	lcd.setCursor(0, 1);
  	Serial.print("Distanza: ");
  	lcd.print("Distanza: ");
    Serial.print(distance);
  	lcd.print(distance);
    Serial.println(" cm");
  	lcd.print(" cm");
    delay(100);
}
