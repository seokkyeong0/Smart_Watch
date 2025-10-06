`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/24 10:26:20
// Design Name: 
// Module Name: counter_divider
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


module counter_divider #(parameter DIV = 1000)(
    input   clk     , 
    input   rst     ,
    output  clk_div  
    );

    // register
    reg [$clog2(DIV)-1:0] count;
    reg tick;

    // output
    assign clk_div = tick;

    // sequential logic
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if(count == DIV - 1) begin
                count <= 0;
                tick <= 1'b1;
            end else begin
                count <= count + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule
