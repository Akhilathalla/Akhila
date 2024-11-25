#include <Arduino.h>
const int inputA = 2;
const int inputB = 3;
const int outputNOR = 4;
const int outputNAND = 5;
void setup() {
  pinMode(inputA, INPUT);
  pinMode(inputB, INPUT);
  pinMode(outputNOR, OUTPUT);
  pinMode(outputNAND, OUTPUT);
}
void loop() {
  int a = digitalRead(inputA);
  int b = digitalRead(inputB);
  int norOutput = !(a || b);
  int nandOutput = !(a && b);
  digitalWrite(outputNOR, norOutput);
  digitalWrite(outputNAND, nandOutput);
}

