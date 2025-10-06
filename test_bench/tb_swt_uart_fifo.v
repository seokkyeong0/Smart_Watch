`timescale 1ns / 1ps

module tb_swt_uart_fifo();
    
    //common signal
    reg clk, rst;
    
    //uart
    reg rx;
    wire tx;

    //wire
    reg echo;
    wire trigger;
    
    //watch signal
    reg [1:0] sw;
    reg btn_L, btn_R, btn_U, btn_D;
    wire [3:0] fnd_com, state_led, led;
    wire [7:0] fnd_data;
    
    //testbench
    reg [7:0] send_data;
    reg [7:0] receive_data;
    
    final_top U_FINAL_TOP(
    .clk       (clk),
    .rst       (rst),
    .rx        (rx),
    .sw        (sw),
    .echo      (echo),
    .dht_io    (dht_io),
    .btn_L     (),
    .btn_R     (),
    .btn_U     (),
    .btn_D     (),
    .trigger   (trigger),
    .fnd_com   (fnd_com),
    .fnd_data  (fnd_data),
    .tx        (tx)               
    );
    
    always #5 clk = ~clk;
    
    initial begin
        #0
        clk         = 0;
        rst         = 1;
        rx          = 1;
        echo        = 0;
        send_data   = 0;
        
        #10
        rst      = 0;
        
        #1_000
        // send data frame
        //send_data = 8'h52; // R : right
        //send_uart(send_data);
        //send_data = 8'h4C; // L : left
        //send_uart(send_data);
        //send_data = 8'h55; // U : up
        //send_uart(send_data);
        //send_data = 8'h44; // D : down
        //send_uart(send_data);
        //send_data = 8'h4D; // M : watch_mode
        //send_uart(send_data);
        //send_data = 8'h48; // H : time_mode
        //send_uart(send_data);
        //send_data = 8'h53; // S : reset
        //send_uart(send_data);

        // send data simulation

        // stopwatch run & stop

        send_data = "M"; // M : watch_mode
        send_uart(send_data);
        #100

        send_data = "M"; // M : watch_mode
        send_uart(send_data);
        #100

        send_data = "T"; // M : watch_mode
        send_uart(send_data);
        #15000
        echo = 1;
        #(58*1000*77);
        echo = 0;
        
        // simulation stop
        #1000;
        $stop;
    end
    
    // task tx -> rx send_uart
    task send_uart(input [7:0] send_data);
        integer i;
        begin
            // start bit
            rx = 0;
            #(104166); // uart 9600bps bit time
            
            // data bit
            for (i = 0; i < 8; i = i + 1)begin
                rx = send_data[i];
                #(104166);
            end
            
            // stop bit
            rx = 1;
            #(104166);
        end
    endtask
    
    // task receive_uart
    task receive_uart(); // no ports
        integer i;
        begin
            // start bit
            wait (!tx);
            #(104166 / 2); // Start bit Middle
            #(104166);
            
            // data bit
            for (i = 0; i < 8; i = i + 1)begin
                receive_data[i] = tx;
                #(104166);
            end
            
            // stop bit
            #(104166);
            #(104166 / 2);
        end
    endtask
endmodule
