//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Fri Nov 14 15:18:12 2025
//Host        : DESKTOP-7CFQ9ND running 64-bit major release  (build 9200)
//Command     : generate_target i2c_cpu_wrapper.bd
//Design      : i2c_cpu_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module i2c_cpu_wrapper
   (SCL_0,
    SDA_0,
    btn,
    led,
    reset,
    sw,
    sys_clock,
    usb_uart_rxd,
    usb_uart_txd);
  output SCL_0;
  inout SDA_0;
  inout [7:0]btn;
  inout [7:0]led;
  input reset;
  inout [7:0]sw;
  input sys_clock;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire SCL_0;
  wire SDA_0;
  wire [7:0]btn;
  wire [7:0]led;
  wire reset;
  wire [7:0]sw;
  wire sys_clock;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  i2c_cpu i2c_cpu_i
       (.SCL_0(SCL_0),
        .SDA_0(SDA_0),
        .btn(btn),
        .led(led),
        .reset(reset),
        .sw(sw),
        .sys_clock(sys_clock),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule
