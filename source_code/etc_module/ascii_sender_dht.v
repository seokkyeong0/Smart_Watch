`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/26 13:58:08
// Design Name: 
// Module Name: ascii_sender_dht
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


module ascii_sender_dht (
    input        clk        ,
    input        rst        ,
    input        start      ,
    input        tx_busy    ,
    input  [7:0] dht_data   ,
    output       send_start ,
    output [7:0] ascii_data 
);

    parameter IDLE = 0, SEND = 1;

    reg state;
    reg r_send;
    reg [5:0] send_cnt;
    reg [1:0] dht_cnt, dht_cnt_next;
    reg [7:0] r_ascii_data [0:23];
    reg [7:0] dht_reg [0:3];

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            dht_cnt <= 0;
            dht_reg[0] <= 0;
            dht_reg[1] <= 0;
            dht_reg[2] <= 0;
            dht_reg[3] <= 0;
        end else begin
            dht_cnt <= dht_cnt_next;
            dht_reg[dht_cnt] <= dht_data;
        end
    end

    always @(*) begin
        if (dht_cnt == 3) begin
            dht_cnt_next = 0;
        end else begin
            dht_cnt_next = dht_cnt + 1;
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state <= IDLE;
            r_send <= 0;
            send_cnt <= 0;
            r_ascii_data[0]  <= "T";
            r_ascii_data[1]  <= "E";
            r_ascii_data[2]  <= "M";
            r_ascii_data[3]  <= "P";
            r_ascii_data[4]  <= " ";
            r_ascii_data[5]  <= "=";
            r_ascii_data[6]  <= " ";
            r_ascii_data[9]  <= " ";
            r_ascii_data[10]  <= "H";
            r_ascii_data[11]  <= "U";
            r_ascii_data[12]  <= "M";
            r_ascii_data[13]  <= "I";
            r_ascii_data[14]  <= "D";
            r_ascii_data[15]  <= "I";
            r_ascii_data[16]  <= "T";
            r_ascii_data[17]  <= "Y";
            r_ascii_data[18]  <= " ";
            r_ascii_data[19]  <= "=";
            r_ascii_data[20]  <= " ";
            r_ascii_data[23] <= "\n";
        end 
        else begin
            r_ascii_data[7]  <= dht_reg[3];
            r_ascii_data[8]  <= dht_reg[2];
            r_ascii_data[21] <= dht_reg[1];
            r_ascii_data[22] <= dht_reg[0];
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
                        if (send_cnt == 23) begin
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

