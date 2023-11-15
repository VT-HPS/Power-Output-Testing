const int buttonPin = 8;
int lastButtonState = LOW;
int debounceDelay = 50;

void setup() {
  pinMode(buttonPin, INPUT);
  Serial.begin(115200); // Set the same Baud Rate as in MATLAB code
}

void loop() {
  int reading = digitalRead(buttonPin);

  if (reading != lastButtonState) {
    lastButtonState = reading;
    delay(debounceDelay);
    Serial.println(reading); // Send the activation state to MATLAB
  }
}
