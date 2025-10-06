`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/22 09:17:30
// Design Name: 
// Module Name: fsm_time
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


module time_control(
    input       clk,
    input       rst,
    input [7:0] pc_data,
    output      m_time
    );

    parameter SEC_MSEC = 0, HOUR_MIN = 1;

    reg c_mode, n_mode;

    assign m_time = (c_mode == SEC_MSEC) ? 1'b0 : 1'b1;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_mode <= SEC_MSEC;
        end else begin
            c_mode <= n_mode;
        end
    end

    always @(*) begin
    n_mode = c_mode;
        case (c_mode)
            SEC_MSEC: begin
                if(pc_data  == 8'h48) begin
                    n_mode = HOUR_MIN;
                end
            end 
            HOUR_MIN: begin
                if(pc_data  == 8'h48) begin
                    n_mode = SEC_MSEC;
                end
            end
            default: n_mode = c_mode; 
        endcase
    end
endmodule

module mode_control(
    input clk,
    input rst,
    input [7:0] pc_data,
    output [1:0] m_sel
    );

    parameter STOPWATCH = 0, WATCH = 1, SR = 2, DHT = 3;
    reg [1:0] c_mode, n_mode;
    
    assign m_sel = (c_mode == STOPWATCH) ? 2'b00 :
                   (c_mode == WATCH)     ? 2'b01 :
                   (c_mode == SR)        ? 2'b10 :
                   (c_mode == DHT)       ? 2'b11 : 2'b00;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_mode <= STOPWATCH;
        end else begin
            c_mode <= n_mode;
        end
    end

    always @(*) begin
    n_mode = c_mode;
        case (c_mode)
            STOPWATCH: begin
                if(pc_data  == 8'h4d) begin
                    n_mode = WATCH;
                end
            end 
            WATCH: begin
                if(pc_data  == 8'h4d) begin
                    n_mode = SR;
                end
            end
            SR: begin
                if(pc_data  == 8'h4d) begin
                    n_mode = DHT;
                end
            end
            DHT: begin
                if(pc_data  == 8'h4d) begin
                    n_mode = STOPWATCH;
                end
            end
            default: n_mode = c_mode; 
        endcase
    end
endmodule