#ifndef Pins_Arduino_h
#define Pins_Arduino_h
#include "variant.h"
#include <stdint.h>
#define USB_VID 0x303a
#define USB_PID 0x1001
// The default Wire will be mapped to PMU and RTC
static const uint8_t SDA = 8;
static const uint8_t SCL = 7;
// Default SPI will be mapped to Radio
static const uint8_t SS = 10; // CS
static const uint8_t MOSI = 11;
static const uint8_t MISO = 13;
static const uint8_t SCK = 12;
#define SPI_MOSI (11)
#define SPI_SCK (12)
#define SPI_MISO (13)
#define SPI_CS (10)
// LEDs
#define LED_BUILTIN (39)
#endif /* Pins_Arduino_h */
