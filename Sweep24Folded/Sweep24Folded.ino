#include <SPI.h>

#define SPI_FREQ_FAST           4000000UL
#define SPI_FREQ_SLOW           500000UL
#define HSPI_MOSI_PIN           26
#define HSPI_SCK_PIN            27
#define VSPI_MOSI_PIN           11
#define VSPI_SCK_PIN            13

#define MUX_EN             1
#define MUX_DIS            0
#define NUM_ELECTRODES     8
// #define NUM_MEAS           NUM_ELECTRODES*NUM_ELECTRODES
#define NUM_MEAS           NUM_ELECTRODES*(NUM_ELECTRODES-1)

#define AD5930_CLK_FREQ    50000000
#define TEST_FREQ          10000
#define NUM_PERIODS        4        // Number of signal periods to measure
#define ADC_AVG            5        // Number of ADC samples to average for each analog reading

// AD5270 commands
#define CMD_WR_RDAC        0x01
#define CMD_RD_RDAC        0x02
#define CMD_ST_RDAC        0x03
#define CMD_RST            0x04
#define CMD_RD_MEM         0x05
#define CMD_RD_ADDR        0x06
#define CMD_WR_CTRL        0x07
#define CMD_RD_CTRL        0x08
#define CMD_SHTDN          0x09

// AD55930 register addresses
#define CTRL_REG           0x00
#define NUM_INCR_REG       0x01
#define DFREQ_LOW_REG      0x02
#define DFREQ_HIGH_REG     0x03
#define TIME_INCR_REG      0x04
#define TIME_BURST_REG     0x08
#define SFREQ_LOW_REG      0x0C
#define SFREQ_HIGH_REG     0x0D

#define CHIP_SEL_AD5930    3  // Chip select pin for AD5930
#define CHIP_SEL_DRIVE     0  // Chip select pin for driving digital rheostat
#define CHIP_SEL_MEAS      1 // Chip select pin for measuring digital rheostat
#define CHIP_SEL_MUX_SRC   24 // Chip select pin for source electrodes MUX - mux1
#define CHIP_SEL_MUX_SINK  28 // Chip select pin for sink electrodes MUX - mux1
#define CHIP_SEL_MUX_VP    30 // Chip select for voltage measurement positive electrodes MUX - mux1
#define CHIP_SEL_MUX_VN    32 // Chip select for voltage measurement negative electrodes MUX - mux1

#define CHIP_SEL_MUX_SRC_2   29 // Chip select pin for source electrodes MUX - mux2
#define CHIP_SEL_MUX_SINK_2  25 // Chip select pin for sink electrodes MUX - mux2
#define CHIP_SEL_MUX_VP_2    33 // Chip select for voltage measurement positive electrodes MUX - mux2
#define CHIP_SEL_MUX_VN_2    31 // Chip select for voltage measurement negative electrodes MUX - mux2

#define AD5930_MSBOUT_PIN  6
#define AD5930_INT_PIN     5  // Pulse high to reset internal state machine
#define AD5930_CTRL_PIN    4  // Pull high to start frequency sweep. Pull low to end the burst. Pull high again to increment frequency
#define AD5930_STANDBY_PIN 2  // Pull high to power down 

#define ADS_PWR            9
#define ADS_OE             10

int16_t sine_table[1024] = {
    0, 3, 6, 9, 12, 15, 18, 21, 25, 28, 31, 34, 37, 40, 43, 47,
    50, 53, 56, 59, 62, 65, 68, 72, 75, 78, 81, 84, 87, 90, 93, 96,
    99, 102, 106, 109, 112, 115, 118, 121, 124, 127, 130, 133, 136, 139, 142, 145,
    148, 151, 154, 157, 160, 163, 166, 169, 172, 175, 178, 181, 184, 187, 190, 193,
    195, 198, 201, 204, 207, 210, 213, 216, 218, 221, 224, 227, 230, 233, 235, 238,
    241, 244, 246, 249, 252, 255, 257, 260, 263, 265, 268, 271, 273, 276, 279, 281,
    284, 287, 289, 292, 294, 297, 299, 302, 304, 307, 310, 312, 314, 317, 319, 322,
    324, 327, 329, 332, 334, 336, 339, 341, 343, 346, 348, 350, 353, 355, 357, 359,
    362, 364, 366, 368, 370, 372, 375, 377, 379, 381, 383, 385, 387, 389, 391, 393,
    395, 397, 399, 401, 403, 405, 407, 409, 411, 413, 414, 416, 418, 420, 422, 423,
    425, 427, 429, 430, 432, 434, 435, 437, 439, 440, 442, 443, 445, 447, 448, 450,
    451, 453, 454, 455, 457, 458, 460, 461, 462, 464, 465, 466, 468, 469, 470, 471,
    473, 474, 475, 476, 477, 478, 479, 481, 482, 483, 484, 485, 486, 487, 488, 489,
    489, 490, 491, 492, 493, 494, 495, 495, 496, 497, 498, 498, 499, 500, 500, 501,
    502, 502, 503, 503, 504, 504, 505, 505, 506, 506, 507, 507, 508, 508, 508, 509,
    509, 509, 510, 510, 510, 510, 511, 511, 511, 511, 511, 511, 511, 511, 511, 511,
    512, 511, 511, 511, 511, 511, 511, 511, 511, 511, 511, 510, 510, 510, 510, 509,
    509, 509, 508, 508, 508, 507, 507, 506, 506, 505, 505, 504, 504, 503, 503, 502,
    502, 501, 500, 500, 499, 498, 498, 497, 496, 495, 495, 494, 493, 492, 491, 490,
    489, 489, 488, 487, 486, 485, 484, 483, 482, 481, 479, 478, 477, 476, 475, 474,
    473, 471, 470, 469, 468, 466, 465, 464, 462, 461, 460, 458, 457, 455, 454, 453,
    451, 450, 448, 447, 445, 443, 442, 440, 439, 437, 435, 434, 432, 430, 429, 427,
    425, 423, 422, 420, 418, 416, 414, 413, 411, 409, 407, 405, 403, 401, 399, 397,
    395, 393, 391, 389, 387, 385, 383, 381, 379, 377, 375, 372, 370, 368, 366, 364,
    362, 359, 357, 355, 353, 350, 348, 346, 343, 341, 339, 336, 334, 332, 329, 327,
    324, 322, 319, 317, 314, 312, 310, 307, 304, 302, 299, 297, 294, 292, 289, 287,
    284, 281, 279, 276, 273, 271, 268, 265, 263, 260, 257, 255, 252, 249, 246, 244,
    241, 238, 235, 233, 230, 227, 224, 221, 218, 216, 213, 210, 207, 204, 201, 198,
    195, 193, 190, 187, 184, 181, 178, 175, 172, 169, 166, 163, 160, 157, 154, 151,
    148, 145, 142, 139, 136, 133, 130, 127, 124, 121, 118, 115, 112, 109, 106, 102,
    99, 96, 93, 90, 87, 84, 81, 78, 75, 72, 68, 65, 62, 59, 56, 53,
    50, 47, 43, 40, 37, 34, 31, 28, 25, 21, 18, 15, 12, 9, 6, 3,
    0, -3, -6, -9, -12, -15, -18, -21, -25, -28, -31, -34, -37, -40, -43, -47,
    -50, -53, -56, -59, -62, -65, -68, -72, -75, -78, -81, -84, -87, -90, -93, -96,
    -99, -102, -106, -109, -112, -115, -118, -121, -124, -127, -130, -133, -136, -139, -142, -145,
    -148, -151, -154, -157, -160, -163, -166, -169, -172, -175, -178, -181, -184, -187, -190, -193,
    -195, -198, -201, -204, -207, -210, -213, -216, -218, -221, -224, -227, -230, -233, -235, -238,
    -241, -244, -246, -249, -252, -255, -257, -260, -263, -265, -268, -271, -273, -276, -279, -281,
    -284, -287, -289, -292, -294, -297, -299, -302, -304, -307, -310, -312, -314, -317, -319, -322,
    -324, -327, -329, -332, -334, -336, -339, -341, -343, -346, -348, -350, -353, -355, -357, -359,
    -362, -364, -366, -368, -370, -372, -375, -377, -379, -381, -383, -385, -387, -389, -391, -393,
    -395, -397, -399, -401, -403, -405, -407, -409, -411, -413, -414, -416, -418, -420, -422, -423,
    -425, -427, -429, -430, -432, -434, -435, -437, -439, -440, -442, -443, -445, -447, -448, -450,
    -451, -453, -454, -455, -457, -458, -460, -461, -462, -464, -465, -466, -468, -469, -470, -471,
    -473, -474, -475, -476, -477, -478, -479, -481, -482, -483, -484, -485, -486, -487, -488, -489,
    -489, -490, -491, -492, -493, -494, -495, -495, -496, -497, -498, -498, -499, -500, -500, -501,
    -502, -502, -503, -503, -504, -504, -505, -505, -506, -506, -507, -507, -508, -508, -508, -509,
    -509, -509, -510, -510, -510, -510, -511, -511, -511, -511, -511, -511, -511, -511, -511, -511,
    -512, -511, -511, -511, -511, -511, -511, -511, -511, -511, -511, -510, -510, -510, -510, -509,
    -509, -509, -508, -508, -508, -507, -507, -506, -506, -505, -505, -504, -504, -503, -503, -502,
    -502, -501, -500, -500, -499, -498, -498, -497, -496, -495, -495, -494, -493, -492, -491, -490,
    -489, -489, -488, -487, -486, -485, -484, -483, -482, -481, -479, -478, -477, -476, -475, -474,
    -473, -471, -470, -469, -468, -466, -465, -464, -462, -461, -460, -458, -457, -455, -454, -453,
    -451, -450, -448, -447, -445, -443, -442, -440, -439, -437, -435, -434, -432, -430, -429, -427,
    -425, -423, -422, -420, -418, -416, -414, -413, -411, -409, -407, -405, -403, -401, -399, -397,
    -395, -393, -391, -389, -387, -385, -383, -381, -379, -377, -375, -372, -370, -368, -366, -364,
    -362, -359, -357, -355, -353, -350, -348, -346, -343, -341, -339, -336, -334, -332, -329, -327,
    -324, -322, -319, -317, -314, -312, -310, -307, -304, -302, -299, -297, -294, -292, -289, -287,
    -284, -281, -279, -276, -273, -271, -268, -265, -263, -260, -257, -255, -252, -249, -246, -244,
    -241, -238, -235, -233, -230, -227, -224, -221, -218, -216, -213, -210, -207, -204, -201, -198,
    -195, -193, -190, -187, -184, -181, -178, -175, -172, -169, -166, -163, -160, -157, -154, -151,
    -148, -145, -142, -139, -136, -133, -130, -127, -124, -121, -118, -115, -112, -109, -106, -102,
    -99, -96, -93, -90, -87, -84, -81, -78, -75, -72, -68, -65, -62, -59, -56, -53,
    -50, -47, -43, -40, -37, -34, -31, -28, -25, -21, -18, -15, -12, -9, -6, -3
};

typedef enum { AD, OP, MONO } meas_t;

extern volatile uint32_t F_CPU_ACTUAL;

// GPIO Pin to analog channel mapping from Arduino\hardware\teensy\avr\cores\teensy4\analog.c
extern const uint8_t pin_to_channel[42];

// Mapping of electrode number (input) to MUX channel (output)
const uint8_t elec_to_mux[32] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 };
// const uint8_t elec_to_mux[32] = {6, 4, 2, 0, 30, 28, 26, 24, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 }; // Front half
// const uint8_t elec_to_mux[32] = {8, 10, 12, 14, 16, 18, 20, 22, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 }; // Back half
// const uint8_t elec_to_mux[32] = {0, 4, 8, 12, 16, 20, 24, 28, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 }; // Alternating round
// const uint8_t elec_to_mux[32] = {32, 30, 28, 26, 24, 22, 20, 18, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 }; // Aligned
// const uint8_t elec_to_mux[32] = {31, 29, 27, 25, 23, 21, 19, 17, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 }; // Off-by-one
// const uint8_t elec_to_mux[32] = { 8, 9, 10, 11, 12, 13, 14, 15, 0, 1, 2, 3, 4, 5, 6, 7, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 };
// const uint8_t elec_to_mux[32] = { 0, 1, 2, 3, 12, 13, 14, 15, 8, 9, 10, 11, 4, 5, 6, 7, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 };

// Global calibration parameters
uint16_t current_gain, voltage_gain;
float sample_rate;
uint16_t samples_per_period;
uint16_t num_samples;
double ref_signal_mag;
double phase_offset;

double signal_rms[NUM_MEAS];    // Store signal RMS data
double signal_mag[NUM_MEAS];    // Store signal magnitude data
double signal_phase[NUM_MEAS];  // Store signal phase data

double cur_frame[NUM_MEAS] = {0};
uint32_t frame_delay = 0;
uint32_t frame_delay_prev = 0;

uint8_t pin_num = 0;
uint16_t rheo_val = 1023;

uint32_t t0;

/* Shift a byte out serially with the given frequency in Hz (<= 500kHz) */
void spi_write(uint8_t data_pin, uint8_t clock_pin, uint32_t freq, uint8_t bit_order, uint8_t mode, uint8_t bits, uint32_t val)
{
    uint32_t period = (freq >= 500000) ? 1 : (500000 / freq);   // Half clock period in uS
    uint8_t cpol = (mode == SPI_MODE2 || mode == SPI_MODE3);
    uint8_t cpha = (mode == SPI_MODE1 || mode == SPI_MODE3);
    uint8_t sck = cpol ? HIGH : LOW;

    uint8_t i;
    uint32_t start_time;

    // Set clock idle for 2 periods
    digitalWrite(clock_pin, sck);
    delayMicroseconds(period*4);

    for (i = 0; i < bits; i++)  {
        start_time = micros();

        // Shift bit out
        if (bit_order == LSBFIRST)
            digitalWrite(data_pin, !!(val & (1 << i)));
        else    
            digitalWrite(data_pin, !!(val & (1 << ((bits-1) - i))));

        // Toggle clock leading edge
        sck = !sck;
        if (cpha) {
            digitalWrite(clock_pin, sck);
            while(micros() - start_time < period);
        } else {
            while(micros() - start_time < period);
            digitalWrite(clock_pin, sck);
        }

        // Toggle clock trailing edge
        start_time = micros();
        sck = !sck;
        if (cpha) {
            digitalWrite(clock_pin, sck);
            while(micros() - start_time < period);
        } else {
            while(micros() - start_time < period);
            digitalWrite(clock_pin, sck);
        }
    }
}

/* Write a 4-bit command and a 10-bit data word */
void AD5270_Write(const int chip_sel, uint8_t cmd, uint16_t data)
{
    uint16_t data_word = ((cmd & 0x0F) << 10) | (data & 0x03FF);
  
//    SPI.beginTransaction(SPISettings(SPI_FREQ, MSBFIRST, SPI_MODE1));
//    digitalWrite(chip_sel, LOW);
//    SPI.transfer16(data_word);
//    digitalWrite(chip_sel, HIGH);
//    SPI.endTransaction();

    digitalWrite(chip_sel, LOW);
    delayMicroseconds(500); // could change smaller for speed
    spi_write(VSPI_MOSI_PIN, VSPI_SCK_PIN, SPI_FREQ_FAST, MSBFIRST, SPI_MODE1, 16, data_word);
    delayMicroseconds(500); // could change smaller for speed
    digitalWrite(chip_sel, HIGH);
}

/* Enable/disable rheostat value changes */
void AD5270_Lock(const int chip_sel, uint8_t lock)
{
    AD5270_Write(chip_sel, CMD_WR_CTRL, lock ? 0 : 0x002);
}

/* Enable/disable hardware shutdown */
void AD5270_Shutdown(const int chip_sel, uint8_t shutdown)
{
    AD5270_Write(chip_sel, CMD_SHTDN, shutdown ? 1 : 0);
}

/* Set the value of the digital rheostat - range is 0-0x3FF (0-100kOhm) */
void AD5270_Set(const int chip_sel, uint16_t val)
{
    AD5270_Write(chip_sel, CMD_WR_RDAC, val);
}

/* Write a 12-bit data word into a register. Register addresses are 4 bits */
void AD5930_Write(uint8_t reg, uint16_t data)
{
    uint16_t data_word = ((reg & 0x0F) << 12) | (data & 0x0FFF);
  
//    SPI.beginTransaction(SPISettings(SPI_FREQ, MSBFIRST, SPI_MODE1));
//    digitalWrite(CHIP_SEL_AD5930, LOW);
//    SPI.transfer16(data_word);
//    digitalWrite(CHIP_SEL_AD5930, HIGH);
//    SPI.endTransaction();

    digitalWrite(CHIP_SEL_AD5930, LOW);
    spi_write(VSPI_MOSI_PIN, VSPI_SCK_PIN, SPI_FREQ_FAST, MSBFIRST, SPI_MODE1, 16, data_word);
    digitalWrite(CHIP_SEL_AD5930, HIGH);
}

/* Program the given frequency (in Hz) */
void AD5930_Set_Start_Freq(uint32_t freq)
{
    uint32_t scaled_freq = (freq * 1.0 / AD5930_CLK_FREQ) * 0x00FFFFFF;
    uint16_t freq_low = scaled_freq & 0x0FFF;
    uint16_t freq_high = (scaled_freq >> 12) & 0x0FFF;

    AD5930_Write(SFREQ_LOW_REG, freq_low);
    AD5930_Write(SFREQ_HIGH_REG, freq_high);
}

void mux_write(const int chip_sel, uint8_t pin_sel, uint8_t enable)
{
//    SPI.beginTransaction(SPISettings(SPI_FREQ, MSBFIRST, SPI_MODE2));
//    digitalWrite(chip_sel, LOW);
//    if (enable)
//        SPI.transfer(pin_sel & 0x1F);
//    else
//        SPI.transfer(0xC0 | (pin_sel & 0x1F));
//    digitalWrite(chip_sel, HIGH);
//    SPI.endTransaction();

    digitalWrite(chip_sel, LOW);
    if (enable)
        spi_write(HSPI_MOSI_PIN, HSPI_SCK_PIN, SPI_FREQ_SLOW, MSBFIRST, SPI_MODE1, 8, pin_sel & 0x1F);
    else
        spi_write(HSPI_MOSI_PIN, HSPI_SCK_PIN, SPI_FREQ_SLOW, MSBFIRST, SPI_MODE1, 8, 0xC0 | (pin_sel & 0x1F));
    digitalWrite(chip_sel, HIGH);
}

/* Return unsigned integer (0-1023) from 10 continuous GPIO pins (14-23, MSb on 14) (takes ~50.1ns) */
uint16_t analog_read()
{
    // GPIO reg bit order: 2, 3, 16, 17, 18, 19, 22, 23, 24, 25, 26, 27
    // Teensy pin order:   1, 0, 19, 18, 14, 15, 17, 16, 22, 23, 20, 21
    // All pins are on GPIO6
    
    uint16_t gpio_reg = *(&GPIO6_DR + 2) >> 16;
    uint16_t val = ((gpio_reg & 0x0200) >> 9) | // Pin 23 (GPIO 25)
                   ((gpio_reg & 0x0100) >> 7) | // Pin 22 (GPIO 24)
                   ((gpio_reg & 0x0800) >> 9) | // Pin 21 (GPIO 27)
                   ((gpio_reg & 0x0400) >> 7) | // Pin 20 (GPIO 26)
                   ((gpio_reg & 0x0003) << 4) | // Pins 19,18 (GPIO 16,17)
                    (gpio_reg & 0x00C0) |       // Pins 17,16 (GPIO 22,23)
                   ((gpio_reg & 0x0008) << 5) | // Pin 15 (GPIO 19)
                   ((gpio_reg & 0x0004) << 7);  // Pin 14 (GPIO 18)
    return val;
}

/* Read 10 continuous GPIO pins (14-23) (takes ~16.8ns) */
uint16_t gpio_read()
{
    return (*(&GPIO6_DR + 2) >> 16);
}

/* Convert GPIO reading to 10-bit unsigned integer (takes ~33.3ns) */
uint16_t gpio_convert(uint16_t gpio_reg)
{  
    uint16_t val = ((gpio_reg & 0x0200) >> 9) | // Pin 23 (GPIO 25)
                   ((gpio_reg & 0x0100) >> 7) | // Pin 22 (GPIO 24)
                   ((gpio_reg & 0x0800) >> 9) | // Pin 21 (GPIO 27)
                   ((gpio_reg & 0x0400) >> 7) | // Pin 20 (GPIO 26)
                   ((gpio_reg & 0x0003) << 4) | // Pins 19,18 (GPIO 17,16)
                    (gpio_reg & 0x00C0) |       // Pins 17,16 (GPIO 22,23)
                   ((gpio_reg & 0x0008) << 5) | // Pin 15 (GPIO 19)
                   ((gpio_reg & 0x0004) << 7);  // Pin 14 (GPIO 18)
    return val;
}

/* Return the magnitude and phase offset of a sinusoidal input signal */
uint32_t read_signal_custom(double * rms, double * mag, double * phase, uint16_t * error_rate, uint8_t debug)
{ 
    uint16_t i, j;
    uint16_t phase_count;
    uint16_t adc_min = 1023;
    uint16_t adc_max = 0;
    uint8_t adc_peak_count = 0;
    uint8_t adc_trough_count = 0;
    uint8_t ref_period_count = 0;
    uint8_t adc_period_count = 0;
    uint8_t phase_readings = 0;
    uint16_t phase_start_index = 0;

    uint16_t gpio_buf[num_samples][ADC_AVG];    // Store raw ADC samples of the input waveform
    uint16_t adc_buf[num_samples];              // Store converted ADC samples of the input waveform
    uint8_t ref_buf[num_samples];               // Store high-low values of the square output waveform
    uint16_t adc_peaks[num_samples];
    uint16_t adc_troughs[num_samples];
    uint16_t phase_cycles[num_samples];
    
    uint32_t time1, time2;
    uint32_t count, num_cycles;
    uint32_t sample_sum, total_sum = 0;
    
    time1 = micros();

    /* Collect samples */
    for(i = 0; i < num_samples; i++)
    { 
        //num_cycles = ((F_CPU_ACTUAL >> 16) * 50) / (1000000000UL >> 16);   // Number of systick cycles equal to 50ns
        num_cycles = 20;
        count = 0;

        // Read GPIO pins
        for (j = 0; j < ADC_AVG; j++)
        {
            while (ARM_DWT_CYCCNT - count < num_cycles);   // Wait set number of cycles since last count
            count = ARM_DWT_CYCCNT;

            gpio_buf[i][j] = gpio_read();
        }
        ref_buf[i] = digitalRead(AD5930_MSBOUT_PIN);
    }

    time2 = micros();

    /* Process samples */
    for(i = 0; i < num_samples; i++)
    {       
        for (j = 0, sample_sum = 0; j < ADC_AVG; j++)
            sample_sum += gpio_convert(gpio_buf[i][j]);    // Get 10-bit ADC value from raw GPIO value
        adc_buf[i] = sample_sum / ADC_AVG;

        /* Store product for RMS calculation */
        int16_t adc_val = (int16_t)adc_buf[i] - 512;
        total_sum += adc_val * adc_val;

        /* Store local max/min */
        if (adc_buf[i] > adc_max)
            adc_max = adc_buf[i];
        if (adc_buf[i] < adc_min)
            adc_min = adc_buf[i];

        if (i > 0)
        {
            /* Signal increasing, entering peak */
            if (adc_buf[i] > 512 && adc_buf[i-1] <= 512)
            {
                /* Ensure that a full half-cycle has been measured */
                if (adc_period_count > 0)
                {
                    adc_troughs[adc_trough_count] = adc_min;
                    adc_trough_count++;
                    adc_min = 1023;

                    /* Discard large phase offsets as error */
                    if (phase_count <= samples_per_period)
                    {
                        phase_cycles[phase_readings] = phase_count;
                        phase_readings++;
                    }
                }
                adc_period_count++;

                /* Record index of first rising zero point */
                if (phase_start_index == 0)
                    phase_start_index = i;
            }

            /* Signal decreasing, entering trough */
            else if (adc_buf[i] < 512 && adc_buf[i-1] >= 512)
            {
                if (adc_period_count > 0)
                {
                    adc_peaks[adc_peak_count] = adc_max;
                    adc_peak_count++;
                    adc_max = 0;

                    /* Discard large phase offsets as error */
                    if (phase_count <= samples_per_period)
                    {
                        phase_cycles[phase_readings] = phase_count;
                        phase_readings++;
                    }
                }
                adc_period_count++;
            }

            phase_count++;
            
            /* Reference signal transition */
            if ((ref_buf[i] && !ref_buf[i-1]) || (!ref_buf[i] && ref_buf[i-1]))
            {
                ref_period_count++;
                phase_count = 0;
            }
        }
    }

    /* Calculate average peaks and troughs */
    for (i = 0, sample_sum =  0; i < adc_peak_count; i++)
        sample_sum += adc_peaks[i];
    adc_max = sample_sum / adc_peak_count;
    for (i = 0, sample_sum = 0; i < adc_trough_count; i++)
        sample_sum += adc_troughs[i];
    adc_min = sample_sum / adc_trough_count;

//    for (i = 0, sample_sum =  0; i < NUM_PERIODS; i++)
//        sample_sum += adc_peaks[i];
//    adc_max = sample_sum / NUM_PERIODS;
//    for (i = 0, sample_sum = 0; i < NUM_PERIODS; i++)
//        sample_sum += adc_troughs[i];
//    adc_min = sample_sum / NUM_PERIODS;

    /* Calculate phase offset */
    int16_t phase_offset_cycles;
    for (i = 0, sample_sum = 0; i < phase_readings; i++)
        sample_sum += phase_cycles[i];
    phase_offset_cycles = sample_sum / phase_readings;

    /* Calculate peak-to-peak magnitude and RMS */
    uint16_t mag_10bit = adc_max - adc_min;
    uint16_t rms_10bit = sqrt(total_sum / num_samples);
//    uint16_t mag_10bit = rms_10bit * sqrt(2) * 2;

    if (rms)
        *rms = (double)rms_10bit * 2.2 / 1024;
    if (mag)
        *mag = (double)mag_10bit * 2.2 / 1024;                                                      
    if (phase)
        *phase = (sample_rate * phase_offset_cycles / 1000000) * TEST_FREQ * 2*PI;

    Serial.print((double)rms_10bit * 2.2 / 1024, 4);
    Serial.print(", ");

    if (error_rate)
    {
        // Compare measured signal to sine wave (only if >=2 period samples are available)
        uint16_t compare_periods = 2;
        if ((num_samples - phase_start_index) >= (samples_per_period * compare_periods))
            *error_rate = sine_compare(adc_buf+phase_start_index, mag_10bit, samples_per_period, compare_periods);
    }

    if (debug)
    {
//        Serial.print(time1 / 1000);
//        Serial.print(".");
//        Serial.println(time1 % 1000);
//        Serial.print(time2 / 1000);
//        Serial.print(".");
//        Serial.println(time2 % 1000);
//        
//        for (i = 0; i < phase_readings; i++)
//        {
//            Serial.println(phase_cycles[i]);
//        }
//    
//        Serial.println(adc_max);
//        Serial.println(adc_min);
//        Serial.print(adc_max - adc_min);
//        Serial.print(mag_avg, 4);
//        Serial.print(*mag, 4);
//        Serial.print("\t");
//        Serial.println(*phase, 4);
//        Serial.println(phase_avg, 4);
//        Serial.println(phase_offset_cycles);
//        Serial.println(sqrt(*real * *real + *imag * *imag), 6);
//    
//        Serial.print("Val 1: ");
//        Serial.println(res1);
//        Serial.print("Val 2: ");
//        Serial.println(res2);
//    
//        Serial.print(ref_period_count);
//        Serial.print("\t");
//        Serial.println(adc_period_count);
//    
//        Serial.println(sample_rate, 4);
    }

    return (time2 - time1);
}


/* Find the optimal number of samples to read the desired number of periods of the input signal */
void calibrate_samples() {

    /* Take 10000 samples to determine sample rate */
    num_samples = 10000;
    uint32_t sample_time = read_signal_custom(NULL, NULL, NULL, NULL, 0);
    
    /* Calculate sample rate and total number of samples */
    sample_rate = (float)sample_time / 10000.0;
    samples_per_period = (1000000 / sample_rate) / TEST_FREQ;
    num_samples = samples_per_period * NUM_PERIODS;
}

/* Find the magnitude and phase offset of the highest voltage differental point */
void calibrate_signal(meas_t drive_type, meas_t meas_type) {

    // Set current source electrodes to origin
    mux_write(CHIP_SEL_MUX_SRC, elec_to_mux[0], MUX_EN);
    if (drive_type == AD)
        mux_write(CHIP_SEL_MUX_SINK, elec_to_mux[1], MUX_EN);
    else if (drive_type == OP)
        mux_write(CHIP_SEL_MUX_SINK, elec_to_mux[16], MUX_EN);

    // Set voltage measurement electrodes to the highest voltage differential point
    if (meas_type == AD) {
        mux_write(CHIP_SEL_MUX_VP, elec_to_mux[30], MUX_EN);
        mux_write(CHIP_SEL_MUX_VN, elec_to_mux[31], MUX_EN);
    } else if (meas_type == OP) {
        mux_write(CHIP_SEL_MUX_VP, elec_to_mux[15], MUX_EN);
        mux_write(CHIP_SEL_MUX_VN, elec_to_mux[31], MUX_EN);
    }

    delay(5);

    /* Determine the magnitude and phase offset of the reference signal */
    ref_signal_mag = 1.0;
    phase_offset = 0;
    uint32_t sample_time = read_signal_custom(NULL, &ref_signal_mag, &phase_offset, NULL, 0);

    mux_write(CHIP_SEL_MUX_SRC, 0, MUX_DIS);
    mux_write(CHIP_SEL_MUX_SINK, 0, MUX_DIS);
    mux_write(CHIP_SEL_MUX_VP, 0, MUX_DIS);
    mux_write(CHIP_SEL_MUX_VN, 0, MUX_DIS);
}

uint16_t sine_compare(uint16_t * signal, uint16_t pk_pk, uint16_t points_per_period, uint8_t num_periods) {

    if (points_per_period == 0)
        return 0;

    uint16_t num_points = points_per_period * num_periods;
    
    uint16_t i;
    uint16_t point_error;
    uint32_t error_sum = 0;

    for (i = 0; i < num_points; i++) {
        // Scale sine wave to match input signal frequency and amplitude
        uint32_t ref_index = ((i * 1024) / points_per_period) % 1024;
        int32_t ref_point = (sine_table[ref_index] * pk_pk) / 1024;

        // Center input signal to 0
        int32_t signal_val = (int16_t)signal[i] - 512;

        point_error = abs(signal_val - ref_point);
        error_sum += point_error;

//        Serial.print(signal_val);
//        Serial.print("\t");
//        Serial.print(ref_point);
//        Serial.print("\t");
//        Serial.println(point_error);
    }
    error_sum = error_sum / num_points;
    return error_sum;
}

void read_frame_custom(meas_t drive_type, meas_t meas_type, double * rms_array, double * mag_array, double * phase_array, uint8_t num_elec, int * elec_to_mux_custom)
{
    int8_t tx_pair, rx_pair;
    uint8_t src_pin, sink_pin, vp_pin, vn_pin;
    uint16_t num_meas = 0;

    for(tx_pair = 0; tx_pair < num_elec; tx_pair++)
    {
        switch (drive_type)
        {
            case AD:
                src_pin = tx_pair;
                sink_pin = (tx_pair + 1) % num_elec;
//                src_pin = tx_pair*2;
//                sink_pin = (tx_pair + 1) % num_elec*2;
                break;
            case OP:
                src_pin = tx_pair;
                sink_pin = (tx_pair + num_elec/2) % num_elec;
                break;
            case MONO:
                src_pin = tx_pair;
                //sink_pin = (tx_pair == 0 ? 31 : 0);
                sink_pin = 0;
                break;
        }
        
        mux_write(CHIP_SEL_MUX_SRC, elec_to_mux_custom[src_pin], MUX_EN);
        mux_write(CHIP_SEL_MUX_SINK, elec_to_mux_custom[sink_pin], MUX_EN);

        delayMicroseconds(150);

        for(rx_pair = 0; rx_pair < num_elec; rx_pair++, num_meas++)
        {
            switch (meas_type)
            {
                case AD:
                    vp_pin = rx_pair;
                    vn_pin = (rx_pair + 1) % num_elec;
//                    vp_pin = rx_pair*2;
//                    vn_pin = (rx_pair + 1) % num_elec*2;
                    break;
                case OP:
                    vp_pin = rx_pair;
                    vn_pin = (rx_pair + num_elec/2) % num_elec;
                    break;
                case MONO:
                    vp_pin = rx_pair;
                    vn_pin = sink_pin;
                    break;
            }

            if (meas_type == MONO)
            {
                if ((vp_pin == src_pin) || (vp_pin == vn_pin) || (src_pin == sink_pin))
                {
                    mag_array[num_meas] = 0;
                    phase_array[num_meas] = 0;
                }
                else 
                {
                    mux_write(CHIP_SEL_MUX_VP, elec_to_mux_custom[vp_pin], MUX_EN);
                    mux_write(CHIP_SEL_MUX_VN, elec_to_mux_custom[vn_pin], MUX_EN);
        
                    delayMicroseconds(100);
        
                    read_signal_custom(rms_array + num_meas, mag_array + num_meas, phase_array + num_meas, NULL, 0);
                }
            }
            else
            {
                if ((vp_pin == src_pin) || (vp_pin == sink_pin) || (vn_pin == src_pin) || (vn_pin == sink_pin))
                {
                }
                else 
                {
                    mux_write(CHIP_SEL_MUX_VP, elec_to_mux_custom[vp_pin], MUX_EN);
                    mux_write(CHIP_SEL_MUX_VN, elec_to_mux_custom[vn_pin], MUX_EN);
                    
                    delayMicroseconds(100);

                    read_signal_custom(rms_array, mag_array, phase_array, NULL, 0);
                }
            }
        }
    }

//    mux_write(CHIP_SEL_MUX_SRC, 0, MUX_DIS);
//    mux_write(CHIP_SEL_MUX_SINK, 0, MUX_DIS);
//    mux_write(CHIP_SEL_MUX_VP, 0, MUX_DIS);
//    mux_write(CHIP_SEL_MUX_VN, 0, MUX_DIS);
}

void setup() 
{
    Serial.begin(115200);

    while(!Serial);

    pinMode(HSPI_MOSI_PIN, OUTPUT);
    pinMode(HSPI_SCK_PIN, OUTPUT);
    pinMode(VSPI_MOSI_PIN, OUTPUT);
    pinMode(VSPI_SCK_PIN, OUTPUT);
    
    pinMode(CHIP_SEL_DRIVE, OUTPUT);
    pinMode(CHIP_SEL_MEAS, OUTPUT);
    pinMode(CHIP_SEL_MUX_SRC, OUTPUT);
    pinMode(CHIP_SEL_MUX_SINK, OUTPUT);
    pinMode(CHIP_SEL_MUX_VP, OUTPUT);
    pinMode(CHIP_SEL_MUX_VN, OUTPUT);
    pinMode(CHIP_SEL_AD5930, OUTPUT);
    
    pinMode(AD5930_INT_PIN, OUTPUT);
    pinMode(AD5930_CTRL_PIN, OUTPUT);
    pinMode(AD5930_STANDBY_PIN, OUTPUT);
    pinMode(AD5930_MSBOUT_PIN, INPUT);

    // ADC input
    pinMode(14, INPUT);
    pinMode(15, INPUT);
    pinMode(16, INPUT);
    pinMode(17, INPUT);
    pinMode(18, INPUT);
    pinMode(19, INPUT);
    pinMode(20, INPUT);
    pinMode(21, INPUT);
    pinMode(22, INPUT);
    pinMode(23, INPUT);

    digitalWrite(CHIP_SEL_DRIVE, HIGH);
    digitalWrite(CHIP_SEL_MEAS, HIGH);
    digitalWrite(CHIP_SEL_MUX_SRC, HIGH);
    digitalWrite(CHIP_SEL_MUX_SINK, HIGH);
    digitalWrite(CHIP_SEL_MUX_VP, HIGH);
    digitalWrite(CHIP_SEL_MUX_VN, HIGH);
    digitalWrite(CHIP_SEL_AD5930, HIGH);
    digitalWrite(AD5930_INT_PIN, LOW);
    digitalWrite(AD5930_CTRL_PIN, LOW);
    digitalWrite(AD5930_STANDBY_PIN, LOW);
    
    digitalWrite(ADS_PWR, LOW); //double-check
    digitalWrite(ADS_OE, LOW);

//    SPI.begin();

    /* B24 = 0 (start freq high and low regs can be written independently)
    * DAC ENABLE = 1 (DAC enabled)
    * SINE/TRI = 1 (sine output)
    * MSBOUTEN = 1 (MSBOUT enabled)
    * CW/BURST = 1 (no mid-scale output after burst)
    * INT/EXT BURST = 1 (burst controlled by CTRL pin)
    * INT/EXT INCR = 1 (frequency increment controlled by CTRL pin)
    * MODE = 1 (frequency saw sweep)
    * SYNCSEL = 0 (SYNCOUT outputs pulse at each freq increment)
    * SYNCOUTEN = 0 (SYNCOUT disabled)
    */
    AD5930_Write(CTRL_REG, 0b011111110011);
    AD5930_Set_Start_Freq(TEST_FREQ);

    AD5270_Lock(CHIP_SEL_DRIVE, 0);
    AD5270_Lock(CHIP_SEL_MEAS, 0);

/* // dsh
   /* Start the frequency sweep */
   digitalWrite(AD5930_CTRL_PIN, HIGH);
   delay(100);

    calibrate_samples();
    // AD5270_Set(CHIP_SEL_MEAS, 50); // MANUALLY SET GAINS
    // AD5270_Set(CHIP_SEL_DRIVE, 500);

    AD5270_Set(CHIP_SEL_MEAS, 10); // MANUALLY SET GAINS
    AD5270_Set(CHIP_SEL_DRIVE, 800);

    
//    calibrate_gain(AD, AD);
//    calibrate_signal(AD, AD);

//    AD5270_Set(CHIP_SEL_DRIVE, 594);
//    AD5270_Set(CHIP_SEL_MEAS, 23);
//    AD5270_Shutdown(CHIP_SEL_DRIVE, 1);
//    AD5270_Shutdown(CHIP_SEL_MEAS, 1);

    mux_write(CHIP_SEL_MUX_SRC, elec_to_mux[0], MUX_EN);
    mux_write(CHIP_SEL_MUX_SINK, elec_to_mux[1], MUX_EN);
    mux_write(CHIP_SEL_MUX_VP, elec_to_mux[0], MUX_EN);
    mux_write(CHIP_SEL_MUX_VN, elec_to_mux[1], MUX_EN);

//    Serial.print("Current gain: ");
//    Serial.println(current_gain);
//    Serial.print("Measurement gain: ");
//    Serial.println(voltage_gain);
//    Serial.print("Sample rate (uS per reading): ");
//    Serial.println(sample_rate, 4);
//    Serial.print("Samples per period: ");
//    Serial.println(samples_per_period);
//    Serial.print("Reference signal magnitude (V): ");
//    Serial.println(ref_signal_mag, 4);
//    Serial.print("Reference signal phase offset (radians): ");
//    Serial.println(phase_offset, 4);

//    uint16_t i;
//
//    /* Read resting impedance state for calibration */
//    for(i = 0; i < 30; i++)
//    {
//        read_frame(AD, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES);
//        
//        uint16_t j;
//        for (j = 0; j < NUM_MEAS; j++)
//        {
//            if (signal_rms[j] != 0)
//                cur_frame[j] = 0.80 * cur_frame[j] + 0.20 * (signal_rms[j]);
//        }
//    }
//
//    Serial.println("origin frame");
//    for (i = 0; i < NUM_MEAS; i++)
//    {                                                                             
//        Serial.println(cur_frame[i], 4);
//    }
t0 = millis(); 
}

void loop() 
{   
//  uint16_t i;

  if (millis() - t0 > 350) {
//  AD5930_Set_Start_Freq(10000);
//  calibrate_samples();
  int elec_to_mux_custom[8] = {5, 17, 19, 21, 13, 11, 9, 7};
  read_frame_custom(OP, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);
  read_frame_custom(AD, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);

  elec_to_mux_custom[0] = 19;
  elec_to_mux_custom[1] = 21;
  elec_to_mux_custom[2] = 23;
  elec_to_mux_custom[3] = 10;
  elec_to_mux_custom[4] = 14;
  elec_to_mux_custom[5] = 15;
  elec_to_mux_custom[6] = 13;
  elec_to_mux_custom[7] = 11;
  read_frame_custom(OP, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);
  read_frame_custom(AD, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);

  elec_to_mux_custom[0] = 23;
  elec_to_mux_custom[1] = 10;
  elec_to_mux_custom[2] = 2;
  elec_to_mux_custom[3] = 0;
  elec_to_mux_custom[4] = 4;
  elec_to_mux_custom[5] = 12;
  elec_to_mux_custom[6] = 14;
  elec_to_mux_custom[7] = 15;
  read_frame_custom(OP, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);
  read_frame_custom(AD, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);

  elec_to_mux_custom[0] = 6;
  elec_to_mux_custom[1] = 8;
  elec_to_mux_custom[2] = 10;
  elec_to_mux_custom[3] = 14;
  elec_to_mux_custom[4] = 15;
  elec_to_mux_custom[5] = 23;
  elec_to_mux_custom[6] = 22;
  elec_to_mux_custom[7] = 20;
  read_frame_custom(OP, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);
  read_frame_custom(AD, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);

  elec_to_mux_custom[0] = 10;
  elec_to_mux_custom[1] = 14;
  elec_to_mux_custom[2] = 16;
  elec_to_mux_custom[3] = 18;
  elec_to_mux_custom[4] = 1;
  elec_to_mux_custom[5] = 3;
  elec_to_mux_custom[6] = 15;
  elec_to_mux_custom[7] = 23;
  read_frame_custom(OP, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);
  read_frame_custom(AD, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES, elec_to_mux_custom);
//  for(i = 0; i < 360; i++)
//  {       
//    Serial.print(signal_rms[i], 4);
//    Serial.print(", ");
//  }

  t0 = millis();

  Serial.print("\n");
  }
}
