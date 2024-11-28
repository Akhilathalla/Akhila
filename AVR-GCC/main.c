#include <avr/io.h>

#define X PB0
#define Y PB1
#define Z PB2

int main() {
  // Initialize ports
  DDRB = 0xFF;

  while (1) {
    // Read inputs
    uint8_t x = (PINB & (1 << X)) ? 1 : 0;
    uint8_t y = (PINB & (1 << Y)) ? 1 : 0;
    uint8_t z = (PINB & (1 << Z)) ? 1 : 0;

    // Calculate output
    uint8_t output = (
      (x && !y && z) || 
      (x && y && z) || 
      (!x && z && !y) || 
      (!x && !z && y)
    );

    // Write output
    PORTB = (output << PB3);
  }

  return 0;
}
