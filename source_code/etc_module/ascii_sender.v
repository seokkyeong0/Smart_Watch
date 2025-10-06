`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/16 18:21:18
// Design Name: 
// Module Name: ascii_sender
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


module ascii_sender (
    input        clk        ,
    input        rst        ,
    input        start      ,
    input        tx_busy    ,
    input  [7:0] time_data  ,
    output       send_start ,
    output [7:0] ascii_data 
);

    parameter IDLE = 0, SEND = 1;

    reg state;
    reg r_send;
    reg [5:0] send_cnt;
    reg [2:0] time_cnt, time_cnt_next;
    reg [7:0] r_ascii_data [0:18];
    reg [7:0] time_reg [0:7];

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            time_cnt <= 0;
            time_reg[0] <= 0;
            time_reg[1] <= 0;
            time_reg[2] <= 0;
            time_reg[3] <= 0;
            time_reg[4] <= 0;
            time_reg[5] <= 0;
            time_reg[6] <= 0;
            time_reg[7] <= 0;
        end else begin
            time_cnt <= time_cnt_next;
            time_reg[time_cnt] <= time_data;
        end
    end

    always @(*) begin
        if (time_cnt == 7) begin
            time_cnt_next = 0;
        end else begin
            time_cnt_next = time_cnt + 1;
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= IDLE;
            r_send <= 0;
            send_cnt <= 0;
            r_ascii_data[0]  <= "T";
            r_ascii_data[1]  <= "I";
            r_ascii_data[2]  <= "M";
            r_ascii_data[3]  <= "E";
            r_ascii_data[4]  <= " ";
            r_ascii_data[5]  <= "=";
            r_ascii_data[6]  <= " ";
            r_ascii_data[9]  <= ":";
            r_ascii_data[12]  <= ":";
            r_ascii_data[15]  <= ":";
            r_ascii_data[18] <= "\n";
        end 
        else begin
            r_ascii_data[7]  <= time_reg[7];
            r_ascii_data[8]  <= time_reg[6];
            r_ascii_data[10]  <= time_reg[5];
            r_ascii_data[11]  <= time_reg[4];
            r_ascii_data[13]  <= time_reg[3];
            r_ascii_data[14]  <= time_reg[2];
            r_ascii_data[16]  <= time_reg[1];
            r_ascii_data[17] <= time_reg[0];
            case (state)
                IDLE: begin
                    send_cnt <= 0;
                    r_send <= 0;
                    if (start) begin
                        state <= SEND;
                        r_send <= 1;
                    end
                end
                SEND: begin
                    r_send <= 1'b0;
                    if(!tx_busy && !r_send) begin
                        r_send <= 1;
                        if (send_cnt == 18) begin
                            r_send <= 1'b0;
                            state <= IDLE;
                        end else begin
                            send_cnt <= send_cnt + 1;
                            state <= SEND;
                        end
                    end 
                end
            endcase
        end
    end

    assign ascii_data = r_ascii_data[send_cnt];
    assign send_start = r_send;
endmodule
