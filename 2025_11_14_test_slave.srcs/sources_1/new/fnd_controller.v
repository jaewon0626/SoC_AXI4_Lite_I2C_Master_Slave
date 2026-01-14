`timescale 1ns / 1ps

module fndController (
    input         clk,
    input         reset,
    input  [13:0] fnd_seg,
    input  [ 3:0] fnd_dot,

    output [ 3:0] fnd_com,
    output [ 7:0] fnd_data
);

    wire tick, fnd_dp;
    wire [7:0] seg_data;
    
    wire [1:0] digit_sel;
    wire [3:0] digit_1, digit_10, digit_100, digit_1000, digit;

    assign fnd_data = {fnd_dp, seg_data[6:0]};

    clk_div_1khz U_Clk_Div_1Khz (
        .clk  (clk),
        .reset(reset),
        .tick (tick)
    );

    counter_2bit U_Conter_2big (
        .clk  (clk),
        .reset(reset),
        .tick (tick),
        .count(digit_sel)
    );

    decoder_2x4 U_Dec_2x4 (
        .x(digit_sel),
        .y(fnd_com)
    );

    digit_splitter U_Digit_Splitter (
        .fnd_seg(fnd_seg),
        .digit_1(digit_1),
        .digit_10(digit_10),
        .digit_100(digit_100),
        .digit_1000(digit_1000)
    );

    mux_4x1 U_Mux_4x1 (
        .sel(digit_sel),
        .x0 (digit_1),
        .x1 (digit_10),
        .x2 (digit_100),
        .x3 (digit_1000),
        .y  (digit)
    );

    BCDtoSEG_decoder U_BCDtoSEG (
        .bcd(digit),
        .seg(seg_data)
    );

    mux_4x1_1bit U_Mux_4x1_1bit (
        .sel(digit_sel),
        .x  (fnd_dot),
        .y  (fnd_dp)
    );
endmodule

module mux_4x1_1bit (
    input      [1:0] sel,
    input      [3:0] x,
    output reg       y
);

    always @(*) begin
        y = 1'b1;
        case (sel)
            2'b00: y = x[0];
            2'b01: y = x[1];
            2'b10: y = x[2];
            2'b11: y = x[3];
        endcase
    end
endmodule

module clk_div_1khz (
    input clk,
    input reset,
    output reg tick
);

    reg [$clog2(100_000)-1 : 0] div_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            div_counter <= 0;
            tick <= 1'b0;
        end else begin
            if (div_counter == 100_000 - 1) begin
                div_counter <= 0;
                tick <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule

module counter_2bit (
    input            clk,
    input            reset,
    input            tick,
    output reg [1:0] count
);

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            if (tick) begin
                count <= count + 1;
            end
        end
    end
endmodule

module decoder_2x4 (
    input      [1:0] x,
    output reg [3:0] y
);

    always @(*) begin
        y = 4'b1111;
        case (x)
            2'b00: y = 4'b1110;
            2'b01: y = 4'b1101;
            2'b10: y = 4'b1011;
            2'b11: y = 4'b0111;
        endcase
    end
endmodule

module digit_splitter (
    input  [13:0] fnd_seg,
    output [ 3:0] digit_1,
    output [ 3:0] digit_10,
    output [ 3:0] digit_100,
    output [ 3:0] digit_1000
);
    assign digit_1    = fnd_seg % 10;
    assign digit_10   = fnd_seg / 10 % 10;
    assign digit_100  = fnd_seg / 100 % 10;
    assign digit_1000 = fnd_seg / 1000 % 10;
endmodule

module mux_4x1 (
    input      [1:0] sel,
    input      [3:0] x0,
    input      [3:0] x1,
    input      [3:0] x2,
    input      [3:0] x3,
    output reg [3:0] y
);

    always @(*) begin
        y = 4'b0000;
        case (sel)
            2'b00: y = x0;
            2'b01: y = x1;
            2'b10: y = x2;
            2'b11: y = x3;
        endcase
    end
endmodule

module BCDtoSEG_decoder (
    input      [3:0] bcd,
    output reg [7:0] seg
);

    always @(bcd) begin
        case (bcd)
            4'h0: seg = 8'hc0;
            4'h1: seg = 8'hf9;
            4'h2: seg = 8'ha4;
            4'h3: seg = 8'hb0;
            4'h4: seg = 8'h99;
            4'h5: seg = 8'h92;
            4'h6: seg = 8'h82;
            4'h7: seg = 8'hf8;
            4'h8: seg = 8'h80;
            4'h9: seg = 8'h90;
            4'ha: seg = 8'h88;
            4'hb: seg = 8'h83;
            4'hc: seg = 8'hc6;
            4'hd: seg = 8'ha1;
            4'he: seg = 8'h86;
            4'hf: seg = 8'h8e;
            default: seg = 8'hff;
        endcase
    end
endmodule
