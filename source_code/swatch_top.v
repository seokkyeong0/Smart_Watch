`timescale 1ns / 1ps

module swatch_top(
    input        clk       ,
    input        rst       ,
    input [7:0]  rx_data   ,
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
    output [7:0] time_data ,
    output [7:0] sw_data   ,
    output [7:0] dht_data  ,
    output [7:0] sr_data   ,
    output [1:0] mode_sel  ,
    output [3:0] mode_led  ,
    output [3:0] digit_led ,
    output       done_dht  ,
    output       done_sr       
);

    // wire
    wire [7:0] fnd_data_watch, fnd_data_stopwatch, fnd_data_sr, fnd_data_dht;
    wire [3:0] fnd_com_watch, fnd_com_stopwatch, fnd_com_sr, fnd_com_dht;
    wire [1:0] m_sel, digit_m;
    wire m_time;

    // LED output
    assign mode_led = (m_sel == 0) ? 4'b0001 :
                      (m_sel == 1) ? 4'b0010 :
                      (m_sel == 2) ? 4'b0100 :
                      (m_sel == 3) ? 4'b1000 : 4'b0000;

    assign digit_led = (m_sel == 1) ? ((digit_m == 0) ? 4'b0001 :
                                       (digit_m == 1) ? 4'b0010 :
                                       (digit_m == 2) ? 4'b0100 :
                                       (digit_m == 3) ? 4'b1000 : 4'b0001) 
                                       : 4'b0000;

    // fnd_data & fnd_com output
    assign fnd_com   = (m_sel == 0) ? fnd_com_stopwatch :
                       (m_sel == 1) ? fnd_com_watch     :
                       (m_sel == 2) ? fnd_com_sr        :
                       (m_sel == 3) ? fnd_com_dht       : 
                       fnd_com_stopwatch;

    assign fnd_data   = (m_sel == 0) ? fnd_data_stopwatch :
                        (m_sel == 1) ? fnd_data_watch     :
                        (m_sel == 2) ? fnd_data_sr        :
                        (m_sel == 3) ? fnd_data_dht       : 
                        fnd_data_stopwatch;

    assign mode_sel  = m_sel;

    time_control U_TIME_SELECT(
        .clk            (clk),
        .rst            (rst | (rx_data  == 8'h53)),
        .pc_data        (rx_data & {8{(m_sel == 0 || m_sel == 1)}}),
        .m_time         (m_time)
    );

    mode_control U_MODE_SELECT(
        .clk(clk),
        .rst(rst | (rx_data  == 8'h53)),
        .pc_data(rx_data),
        .m_sel(m_sel)
    );

    // STOPWATCH module
    stopwatch U_SW(
        .clk(clk),
        .rst(rst | (rx_data  == 8'h53)),
        .sw(m_time),
        .btn_L(btn_L & (m_sel == 0)) ,  // clear
        .btn_R(btn_R & (m_sel == 0)) ,  // run_stop
        .pc_data(rx_data & {8{(m_sel == 0)}}),
        .fnd_com(fnd_com_stopwatch),
        .fnd_data(fnd_data_stopwatch),
        .sw_data (sw_data)
    );

    // WATCH module
    watch U_WATCH(
        .clk(clk),
        .rst(rst | (rx_data  == 8'h53)),
        .sw(m_time),
        .btn_L((btn_L & (m_sel == 1))),  // clear
        .btn_R((btn_R & (m_sel == 1))),  // digit move
        .btn_U((btn_U & (m_sel == 1))),  // increase
        .btn_D((btn_D & (m_sel == 1))),  // decrease
        .pc_data(rx_data & {8{(m_sel == 1)}}),
        .fnd_com(fnd_com_watch),
        .fnd_data(fnd_data_watch),
        .time_data(time_data),
        .digit_m()
    );

    // SR04 module
    ultra_sensor_top U_SR04_SENSOR(
        .clk        (clk),
        .rst        (rst | (rx_data  == 8'h53)),
        .start      (rx_data & {8{(m_sel == 2)}}),
        .echo       (echo),
        .trigger    (trigger),
        .fnd_data   (fnd_data_sr),
        .fnd_com    (fnd_com_sr),
        .dist_data  (sr_data),
        .done       (done_sr)
    );

    // DHT11 module
    dht11_sensor U_DHT_SENSOR(
        .clk            (clk),
        .rst            (rst | (rx_data  == 8'h53)),
        .start          (rx_data & {8{(m_sel == 3)}}),
        .dht_io         (dht_io),
        .dht_data       (dht_data),
        .fnd_data       (fnd_data_dht),   
        .fnd_com        (fnd_com_dht),
        .done           (done_dht)      
    );
endmodule

