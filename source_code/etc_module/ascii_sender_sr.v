`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/27 15:53:15
// Design Name: 
// Module Name: ascii_sender_sr
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


module ascii_sender_sr(
    input        clk        ,
    input        rst        ,
    input        start      ,
    input        tx_busy    ,
    input  [7:0] sr_data    ,
    output       send_start ,
    output [7:0] ascii_data 
    );

    parameter IDLE = 0, SEND = 1;

    reg state;
    reg r_send;
    reg [4:0] send_cnt;
    reg [1:0] sr_cnt, sr_cnt_next;
    reg [7:0] r_ascii_data [0:19];
    reg [7:0] sr_reg [0:3];

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            sr_cnt <= 0;
            sr_reg[0] <= 0;
            sr_reg[1] <= 0;
            sr_reg[2] <= 0;
            sr_reg[3] <= 0;
        end else begin
            sr_cnt <= sr_cnt_next;
            sr_reg[sr_cnt] <= sr_data;
        end
    end

    always @(*) begin
        if (sr_cnt == 3) begin
            sr_cnt_next = 0;
        end else begin
            sr_cnt_next = sr_cnt + 1;
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= IDLE;
            r_send <= 0;
            send_cnt <= 0;
            r_ascii_data[0]  <= "D";
            r_ascii_data[1]  <= "I";
            r_ascii_data[2]  <= "S";
            r_ascii_data[3]  <= "T";
            r_ascii_data[4]  <= "A";
            r_ascii_data[5]  <= "N";
            r_ascii_data[6]  <= "C";
            r_ascii_data[7]  <= "E";
            r_ascii_data[8]  <= " ";
            r_ascii_data[9]  <= "=";
            r_ascii_data[10]  <= " ";
            r_ascii_data[14]  <= ".";
            r_ascii_data[16]  <= " ";
            r_ascii_data[17]  <= "c";
            r_ascii_data[18]  <= "m";
            r_ascii_data[19]  <= "\n";
        end 
        else begin
            r_ascii_data[11]  <= sr_reg[3];
            r_ascii_data[12]  <= sr_reg[2];
            r_ascii_data[13] <= sr_reg[1];
            r_ascii_data[15] <= sr_reg[0];
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
                        if (send_cnt == 19) begin
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
