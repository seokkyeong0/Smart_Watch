`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/19 11:08:35
// Design Name: 
// Module Name: uart_fifo
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


module uart_fifo(
    input        clk       ,
    input        rst       ,
    input        rx        ,
    input  [1:0] mode_sel  ,
    input  [7:0] time_data ,
    input  [7:0] sw_data   ,
    input  [7:0] sr_data   ,
    input  [7:0] dht_data  ,
    input        sr_done   ,
    input        dht_done  ,
    output [7:0] rx_data   ,
    output       tx        
);
    
    // register
     reg [7:0] rx_data_reg;

    // wire
    wire [7:0] w_rx_data;
    wire [7:0] w_tx_data;
    wire [7:0] w_lb_data;
    wire [7:0] w_time_data;
    wire [7:0] w_sw_data;
    wire [7:0] w_dht_data;
    wire [7:0] w_sr_data;
    wire [7:0] w_data;

    wire w_send_start_w;
    wire w_send_start_sw;
    wire w_send_start_dht;
    wire w_send_start_sr;
    wire w_send_start;

    wire w_rx_done;
    wire w_rx_full;

    wire w_tx_busy;
    wire w_tx_start;

    wire w_lb_push;
    wire w_lb_pop;
    
    //output & assign
    assign rx_data = rx_data_reg;
    assign w_send_start = (w_send_start_w) ? w_send_start_w : 
                          (w_send_start_sw) ? w_send_start_sw : 
                          (w_send_start_sr) ? w_send_start_sr :
                          (w_send_start_dht) ? w_send_start_dht : 0; 
    assign w_data = (w_send_start_w) ? w_time_data : 
                    (w_send_start_sw) ? w_sw_data : 
                    (w_send_start_sr) ? w_sr_data :
                    (w_send_start_dht) ? w_dht_data : 0;

    // sequential logic for tick signal
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            rx_data_reg <= 0;
        end else begin
            if(!w_lb_push) begin
                rx_data_reg <= w_lb_data;
            end else rx_data_reg <= 0; 
        end
    end

    // UART MAIN
    uart U_UART(
        .clk(clk),
        .rst(rst),
        .tx_start(~(w_tx_start)),
        .rx(rx),
        .tx_data(w_tx_data),
        .tx(tx),
        .tx_busy(w_tx_busy),
        .rx_data(w_rx_data),
        .rx_busy(),
        .rx_done(w_rx_done)
    );

    // UART FIFO RX
    fifo U_FIFO_RX(
        .clk    (clk),
        .rst    (rst),
        .w_data (w_rx_data),
        .push   (w_rx_done),
        .pop    (~(w_lb_pop)),
        .r_data (w_lb_data),
        .full   (w_rx_full),
        .empty  (w_lb_push)
    );

    // STOPWATCH DATA SENDER
    ascii_sender U_ASCII_SENDER_STOPWATCH(
    .clk        (clk),
    .rst        (rst),
    .start      ((w_lb_push) & (rx_data_reg == "T") & (mode_sel == 0)),
    .tx_busy    (w_tx_busy),
    .time_data  (sw_data),
    .send_start (w_send_start_sw),
    .ascii_data (w_sw_data)
    );

    // WATCH DATA SENDER
    ascii_sender U_ASCII_SENDER_WATCH(
    .clk        (clk),
    .rst        (rst),
    .start      ((w_lb_push) & (rx_data_reg == "T") & (mode_sel == 1)),
    .tx_busy    (w_tx_busy),
    .time_data  (time_data),
    .send_start (w_send_start_w),
    .ascii_data (w_time_data)
    );

    // SR04 DATA SENDER
    ascii_sender_sr U_ASCII_SENDER_SR(
        .clk        (clk),
        .rst        (rst),
        .start      (sr_done & (mode_sel == 2)),
        .tx_busy    (w_tx_busy),
        .sr_data    (sr_data),
        .send_start (w_send_start_sr),
        .ascii_data (w_sr_data)
    );

    // DHT11 DATA SENDER
    ascii_sender_dht U_ASCII_SENDER_DHT(
        .clk        (clk),
        .rst        (rst),
        .start      (dht_done & (mode_sel == 3)),
        .tx_busy    (w_tx_busy),
        .dht_data   (dht_data),
        .send_start (w_send_start_dht),
        .ascii_data (w_dht_data)
    );
    
    // UART FIFO TX
    fifo U_FIFO_TX(
        .clk    (clk),
        .rst    (rst),
        .w_data (w_data),
        .push   (w_send_start),
        .pop    (~(w_tx_busy)),
        .r_data (w_tx_data),
        .full   (w_lb_pop),
        .empty  (w_tx_start)
    );
endmodule

module uart(
    input        clk,
    input        rst,
    input        tx_start,
    input        rx,
    input  [7:0] tx_data,
    output       tx,
    output       tx_busy,
    output [7:0] rx_data,
    output       rx_busy,
    output       rx_done
);

    wire w_b_tick;

    uart_rx U_UART_RX(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick), // same b_tick with UART TX
        .rx(rx),
        .rx_data(rx_data),
        .rx_busy(rx_busy),
        .rx_done(rx_done)
    );

    uart_tx U_UART_TX(
        .clk(clk),
        .rst(rst),
        .start(tx_start),
        .b_tick(w_b_tick), // same b_tick with UART RX
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    baud_tick_gen #(.BAUD(9600)) U_BT_GEN(
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick)
    );
endmodule