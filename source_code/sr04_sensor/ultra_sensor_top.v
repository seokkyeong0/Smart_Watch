`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/24 11:10:20
// Design Name: 
// Module Name: ultra_sensor_top
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


module ultra_sensor_top(
    input        clk        ,
    input        rst        ,
    input  [7:0] start      ,
    input        echo       ,
    output       trigger    ,
    output [7:0] fnd_data   ,
    output [3:0] fnd_com    ,
    output [7:0] dist_data  ,
    output       done       
);

    wire w_tick;
    wire [11:0] w_dist;

    counter_divider #(.DIV(10)) U_CLK_DIV(
        .clk     (clk), 
        .rst     (rst),
        .clk_div (w_tick) 
    );

    fsm_ultra_sensor U_SENSOR_CU(
        .clk      (clk),
        .rst      (rst),
        .start    (start),
        .echo     (echo),
        .tick     (w_tick),
        .trigger  (trigger),
        .distance (w_dist),
        .done     (done)
    );

    fnd_controller_sr04 U_FND_CTRL(
        .clk       (clk),
        .rst       (rst),
        .i_data    (w_dist),
        .fnd_com   (fnd_com),
        .fnd_data  (fnd_data),
        .dist_data (dist_data)
    );
endmodule
