<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The SPI peripheral receives a 16 bit write (1 bit R/W (read only), 7 bit address, 8 bit data) and stores it on one of 5 registers. The pwm peripheral then reads those 5 registers to drive its 16 outputs. Its outputs can have the following states:
- on
- off
- pwm_mode: around a 3kHz signal at the chosen duty cycle

## How to test

Pins:
- SCLK on ui_in[0]
- COPI on ui_in[1]
- nCS on ui_in[2]

Outputs:
- OUT0 to OUT7 on uo_out
- OUT8 to OUT15 on uio_out

Use SPI in mode 0, write only. 16 bits per transaction, MSB first.
- bit 1: R/W (must be 1 for write, reads ignored)
- bit 2-8: memory address
- bit 9-16: data

Register map:

| Addr   | Register          | Description                              | Reset Value |
|--------|-------------------|------------------------------------------|-------------|
| `0x00` | `en_reg_out_7_0`  | Enable outputs on `uo_out[7:0]`          | `0x00`      |
| `0x01` | `en_reg_out_15_8` | Enable outputs on `uio_out[7:0]`         | `0x00`      |
| `0x02` | `en_reg_pwm_7_0`  | Enable PWM for `uo_out[7:0]`             | `0x00`      |
| `0x03` | `en_reg_pwm_15_8` | Enable PWM for `uio_out[7:0]`            | `0x00`      |
| `0x04` | `pwm_duty_cycle`  | PWM Duty Cycle (`0x00`=0%, `0xFF`=100%)  | `0x00`      |

Example Sequence:
To make OUT0 pulse at 50%:
- write 0x80 to 0x04
- write 0x01 to 0x02
- write 0x01 to 0x00

## External hardware

- An SPI controller to write
