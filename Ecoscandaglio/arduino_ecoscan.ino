const int trigPin = 9;
const int echoPin = 10;


float duration; // tempo tra invio e ritorno del segnale
float distance; // distanza dell'oggetto

void setup()
{
  Serial.begin(9600);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
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
    Serial.println(distance);
    delay(100);
}
