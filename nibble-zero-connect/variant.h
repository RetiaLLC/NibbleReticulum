#define I2C_SDA 8
#define I2C_SCL 7
#define USE_SX1262
#define LORA_SCK 12
#define LORA_MISO 13
#define LORA_MOSI 11
#define LORA_CS 10
#define LORA_RESET 6
#ifdef USE_SX1262
#define SX126X_CS LORA_CS
#define SX126X_DIO1 4
#define SX126X_BUSY 5
#define SX126X_RESET LORA_RESET
#define SX126X_DIO2_AS_RF_SWITCH
#define SX126X_DIO3_TCXO_VOLTAGE 1.8
#endif
#define LED_POWER 39
#define LED_STATE_ON 1

// --- NeoPixel (Ambient Lighting) ---
#define HAS_NEOPIXEL 1
#define NEOPIXEL_COUNT 1
#define NEOPIXEL_DATA 21
#define NEOPIXEL_TYPE (NEO_GRB + NEO_KHZ800)

#define BUTTON_PIN 1
#define BUTTON_NEED_PULLUP

// --- Virtual Trackball (Input Broker) ---
#define HAS_TRACKBALL 1
#define TB_LEFT 40    
#define TB_DOWN 41    
#define TB_UP 42    
#define TB_RIGHT 45   
#define TB_PRESS 2    
#define TB_DIRECTION FALLING 

// --- Safety for Flipper (Pin 18) ---
// #define PIN_FLIPPER_DETECT 18

// Disable conflicting peripherals on Pin 18
#define RX1 -1
#define TX1 -1
#define RX2 -1
#define TX2 -1
#define I2S_SD -1
#define I2S_WS -1
#define I2S_SCK -1
#define I2S_BCK -1
