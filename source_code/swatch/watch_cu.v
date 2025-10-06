`timescale 1ns / 1ps

module watch_cu(
    input clk,
    input rst,
    input btn_clear,
    input btn_digit_move,
    input btn_inc,
    input btn_dec,
    input [7:0] pc_data,
    output reg [1:0] digit_mode,
    output reg inc,              
    output reg dec,              
    output reg clear             
    );

    parameter IDLE = 2'b00,     // 기본 ?��?�� (digit_mode = 00)
              ADJUST_SEC = 2'b01,   // �? 조정 모드 (digit_mode = 01)
              ADJUST_MIN = 2'b10,   // �? 조정 모드 (digit_mode = 10)
              ADJUST_HOUR = 2'b11;  // ?�� 조정 모드 (digit_mode = 11)

    reg [1:0] c_state, n_state;

    reg [3:0] n_state_led;
    reg n_inc, n_dec, n_clear;

    // state register
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            c_state <= IDLE;
            digit_mode <= IDLE;
            inc <= 1'b0;
            dec <= 1'b0;
            clear <= 1'b0;
        end else begin
            c_state <= n_state;
            digit_mode <= n_state;
            inc <= n_inc;
            dec <= n_dec;
            clear <= n_clear;
        end
    end

    // next state combinational logic
    always @(*) begin
        n_state = c_state;
        n_inc = 1'b0;
        n_dec = 1'b0;
        n_clear = 1'b0;
        case (c_state)
            IDLE: begin
                n_state_led = 4'b0001;
                if (btn_digit_move || (pc_data ==  8'h52)) begin
                    n_state = ADJUST_SEC;
                    n_state_led = 4'b0010;
                end else if (btn_clear || (pc_data ==  8'h4c) ) begin
                    n_clear = 1'b1;
                end
            end
            ADJUST_SEC: begin
                if (btn_digit_move || (pc_data ==  8'h52)) begin
                    n_state = ADJUST_MIN;
                    n_state_led = 4'b0100;
                end else if (btn_inc || (pc_data ==  8'h55) ) begin
                    n_inc = 1'b1;
                end else if (btn_dec || (pc_data ==  8'h44) ) begin
                    n_dec = 1'b1;
                end else if (btn_clear || (pc_data ==  8'h4c) ) begin
                    n_clear = 1'b1;
                end
            end
            ADJUST_MIN: begin // �? 조정 모드
                if (btn_digit_move || (pc_data ==  8'h52) ) begin
                    n_state = ADJUST_HOUR; // ?�� 조정 모드�? ?��?��
                    n_state_led = 4'b1000;
                end else if (btn_inc || (pc_data ==  8'h55)  ) begin
                    n_inc = 1'b1;
                end else if (btn_dec || (pc_data ==  8'h44)  ) begin
                    n_dec = 1'b1;
                end else if (btn_clear || (pc_data ==  8'h4c) ) begin
                    n_clear = 1'b1;
                end
            end
            ADJUST_HOUR: begin // ?�� 조정 모드
                if (btn_digit_move || (pc_data ==  8'h52) ) begin
                    n_state = IDLE; // ?��?�� �? 조정 모드�? ?��?�� (?��?��)
                    n_state_led = 4'b0001;
                end else if (btn_inc || (pc_data ==  8'h55) ) begin
                    n_inc = 1'b1;
                end else if (btn_dec || (pc_data ==  8'h44)  ) begin
                    n_dec = 1'b1;
                end else if (btn_clear || (pc_data ==  8'h4c)  ) begin
                    n_clear = 1'b1;
                end
            end
            default: begin
                n_state = IDLE; // latch 방�?
            end
        endcase
    end
endmodule
