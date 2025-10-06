`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/21 15:45:03
// Design Name: 
// Module Name: swt_uart_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module final_top(
    input        clk       ,
    input        rst       ,
    input        rx        ,
    input [1:0]  sw        ,
    input        echo      ,
    inout        dht_io    ,
    input        btn_L     ,
    input        btn_R     ,
    input        btn_U     ,
    input        btn_D     ,
    output       trigger   ,
    output [3:0] fnd_com   ,
    output [7:0] fnd_data  ,
    output [3:0] m_led     ,
    output [3:0] d_led     ,
    output tx                             
);

    wire [7:0] w_rx_data;
    wire [7:0] w_time_data;
    wire [7:0] w_sw_data;
    wire [7:0] w_sr_data;
    wire [7:0] w_dht_data;
    wire [1:0] w_mode_sel;
    wire w_sr_done;
    wire w_dht_done;

    uart_fifo U_UART_FIFO(
        .clk       (clk),
        .rst       (rst),
        .rx        (rx),
        .mode_sel  (w_mode_sel),
        .time_data (w_time_data),
        .sw_data   (w_sw_data),
        .sr_data   (w_sr_data),
        .dht_data  (w_dht_data),
        .sr_done   (w_sr_done),
        .dht_done  (w_dht_done),
        .rx_data   (w_rx_data),
        .tx        (tx)
    );

    swatch_top U_SYSTEM_TOP(
        .clk       (clk),
        .rst       (rst),
        .rx_data   (w_rx_data),
        .sw        (sw),
        .echo      (echo),
        .trigger   (trigger),
        .dht_io    (dht_io),
        .btn_L     (btn_L),
        .btn_R     (btn_R),
        .btn_U     (btn_U),
        .btn_D     (btn_D),
        .fnd_com   (fnd_com),
        .fnd_data  (fnd_data),
        .time_data (w_time_data),
        .sw_data   (w_sw_data),
        .sr_data   (w_sr_data),
        .dht_data  (w_dht_data),
        .mode_sel  (w_mode_sel),
        .mode_led  (m_led),
        .digit_led (d_led),
        .done_dht  (w_dht_done),
        .done_sr   (w_sr_done)
    );
endmodule
