`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/25 11:42:13
// Design Name: 
// Module Name: dht11_sensor
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


module dht11_sensor(
    input        clk            ,
    input        rst            ,
    input  [7:0] start          ,
    inout        dht_io         ,
    output [7:0] dht_data       ,
    output [7:0] fnd_data       ,   
    output [3:0] fnd_com        ,
    output       done                 
    );

    wire w_tick;
    wire w_vaild;
    wire w_done;
    wire [39:0] w_data;

    counter_divider #(.DIV(1000)) U_CLK_DIV_10US(
        .clk     (clk), 
        .rst     (rst),
        .clk_div (w_tick) 
    );

    fsm_dht11 U_FSM_DHT(
        .clk    (clk)    ,
        .rst    (rst)    ,
        .start  (start)  ,
        .tick   (w_tick) ,
        .dht_io (dht_io) ,
        .data   (w_data)  ,
        .vaild  (vaild)  ,
        .done   (done)   
    );

    fnd_controller_dht U_FND_CTRL_DHT(
        .clk        (clk),
        .rst        (rst),
        .i_data     (w_data),
        .dht_data   (dht_data),
        .fnd_com    (fnd_com),
        .fnd_data   (fnd_data)
    );
endmodule
