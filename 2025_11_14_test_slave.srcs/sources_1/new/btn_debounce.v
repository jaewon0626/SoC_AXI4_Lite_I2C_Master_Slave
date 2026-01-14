`timescale 1ns / 1ps

module btn_debounce #(
    parameter MAX_COUNT = 100_000
) (
    input  clk,
    input  reset,
    input  i_btn,
    output o_btn
);

    reg [7:0] q_reg, q_next;
    reg edge_detect;
    
    wire btn_debounce;

    reg [$clog2(MAX_COUNT)-1:0] counter;
    reg r_1khz;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= 0;
            r_1khz  <= 0;
        end else begin
            if (counter == MAX_COUNT - 1) begin
                counter <= 0;
                r_1khz  <= 1'b1;
            end else begin  // 1khz 1tick.
                counter <= counter + 1;
                r_1khz  <= 1'b0;
            end
        end
    end

    // state logic, shift register 
    always @(posedge r_1khz, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end
    end

    always @(i_btn, r_1khz) begin

        q_next = {i_btn, q_reg[7:1]};
    end

    assign btn_debounce = &q_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_detect <= 1'b0;
        end else begin
            edge_detect <= btn_debounce;

        end
    end

    assign o_btn = btn_debounce & (~edge_detect);

endmodule
