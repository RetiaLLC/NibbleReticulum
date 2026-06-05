#include "esp32-hal-gpio.h"
#include "Arduino.h"
#include "driver/gpio.h"
#include "esp_rom_gpio.h"

extern "C" void initVariant() {
    // Aggressively neutralize GPIO 18 to prevent interference from Flipper Zero
    // 1. Reset the pin (disables IO mux)
    gpio_reset_pin(GPIO_NUM_18);
    // 2. Set direction to disable (high impedance, no input, no output)
    gpio_set_direction(GPIO_NUM_18, GPIO_MODE_DISABLE);
    // 3. Disable pull-ups/pull-downs (floating)
    gpio_set_pull_mode(GPIO_NUM_18, GPIO_FLOATING);
    // 4. Detach from GPIO matrix input (route signal to 0x38 which is constant low)
    gpio_matrix_in(GPIO_NUM_18, 0x38, false);
    // 5. Detach from GPIO matrix output (route nothing to the pin)
    gpio_matrix_out(GPIO_NUM_18, SIG_GPIO_OUT_IDX, false, false);
}
