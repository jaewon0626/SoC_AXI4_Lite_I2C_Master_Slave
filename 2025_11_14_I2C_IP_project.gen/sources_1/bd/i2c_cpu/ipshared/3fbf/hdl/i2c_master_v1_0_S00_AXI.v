`timescale 1 ns / 1 ps

module i2c_master_v1_0_S00_AXI #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
) (
    // I2C 인터페이스 포트 추가
    output wire SCL,
    inout  wire SDA,

    // 기존 AXI 포트들...
    input wire S_AXI_ACLK,
    input wire S_AXI_ARESETN,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input wire [2 : 0] S_AXI_AWPROT,
    input wire S_AXI_AWVALID,
    output wire S_AXI_AWREADY,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input wire S_AXI_WVALID,
    output wire S_AXI_WREADY,
    output wire [1 : 0] S_AXI_BRESP,
    output wire S_AXI_BVALID,
    input wire S_AXI_BREADY,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input wire [2 : 0] S_AXI_ARPROT,
    input wire S_AXI_ARVALID,
    output wire S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [1 : 0] S_AXI_RRESP,
    output wire S_AXI_RVALID,
    input wire S_AXI_RREADY
);

    // 기존 AXI 신호들 (변경 없음)
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
    reg                            axi_awready;
    reg                            axi_wready;
    reg [                   1 : 0] axi_bresp;
    reg                            axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0] axi_araddr;
    reg                            axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0] axi_rdata;
    reg [                   1 : 0] axi_rresp;
    reg                            axi_rvalid;

    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH / 32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 1;

    // 레지스터들
    reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;
    reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg1;
    reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg2;
    reg     [C_S_AXI_DATA_WIDTH-1:0] slv_reg3;
    wire                             slv_reg_rden;
    wire                             slv_reg_wren;
    reg     [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;
    integer                          byte_index;
    reg                              aw_en;

    // ========================================
    // 여기서부터 I2C 관련 추가 부분
    // ========================================

    // I2C Master 신호들
    wire    [                   7:0] i2c_tx_data;
    wire                             i2c_start;
    wire                             i2c_en;
    wire                             i2c_stop;
    wire                             i2c_tx_done;
    wire                             i2c_ready;
    wire    [                   7:0] i2c_rx_data;

    // 레지스터 맵:
    // slv_reg0[7:0]   = tx_data
    // slv_reg0[8]     = i2c_start
    // slv_reg0[9]     = i2c_en
    // slv_reg0[10]    = stop
    // slv_reg1[7:0]   = rx_data (읽기 전용)
    // slv_reg1[8]     = tx_done (읽기 전용)
    // slv_reg1[9]     = ready (읽기 전용)

    assign i2c_tx_data = slv_reg0[7:0];
    assign i2c_start   = slv_reg0[8];
    assign i2c_en      = slv_reg0[9];
    assign i2c_stop    = slv_reg0[10];

    // I2C_MASTER 인스턴스
    I2C_MASTER i2c_master_inst (
        .clk(S_AXI_ACLK),
        .reset(~S_AXI_ARESETN),  // Active HIGH reset으로 변환
        .tx_data(i2c_tx_data),
        .i2c_start(i2c_start),
        .i2c_en(i2c_en),
        .stop(i2c_stop),
        .tx_done(i2c_tx_done),
        .ready(i2c_ready),
        .rx_data(i2c_rx_data),
        .SCL(SCL),
        .SDA(SDA)
    );

    // ========================================
    // 기존 AXI 로직들 (거의 동일)
    // ========================================

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;

    // axi_awready 생성 (변경 없음)
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awready <= 1'b0;
            aw_en <= 1'b1;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                axi_awready <= 1'b1;
                aw_en <= 1'b0;
            end else if (S_AXI_BREADY && axi_bvalid) begin
                aw_en <= 1'b1;
                axi_awready <= 1'b0;
            end else begin
                axi_awready <= 1'b0;
            end
        end
    end

    // axi_awaddr 래치 (변경 없음)
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awaddr <= 0;
        end else begin
            if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end

    // axi_wready 생성 (변경 없음)
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_wready <= 1'b0;
        end else begin
            if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en) begin
                axi_wready <= 1'b1;
            end else begin
                axi_wready <= 1'b0;
            end
        end
    end

    // 레지스터 쓰기 로직 (수정됨)
    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else begin
            // I2C 상태를 slv_reg1에 자동으로 업데이트
            slv_reg1[7:0] <= i2c_rx_data;
            slv_reg1[8] <= i2c_tx_done;
            slv_reg1[9] <= i2c_ready;
            slv_reg1[31:10] <= 22'b0;  // 나머지 비트는 0

            if (slv_reg_wren) begin
                case (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
                    2'h0:  // Control Register (쓰기 가능)
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                    2'h1:  // Status Register (읽기 전용, 쓰기 무시)
                    slv_reg1 <= slv_reg1;
                    2'h2:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                    2'h3:
                    for (
                        byte_index = 0;
                        byte_index <= (C_S_AXI_DATA_WIDTH / 8) - 1;
                        byte_index = byte_index + 1
                    )
                    if (S_AXI_WSTRB[byte_index] == 1) begin
                        slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    end
                    default: begin
                        slv_reg0 <= slv_reg0;
                        slv_reg1 <= slv_reg1;
                        slv_reg2 <= slv_reg2;
                        slv_reg3 <= slv_reg3;
                    end
                endcase
            end
        end
    end

    // Write response 로직 (변경 없음)
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_bvalid <= 0;
            axi_bresp  <= 2'b0;
        end else begin
            if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
        begin
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b0;
            end else begin
                if (S_AXI_BREADY && axi_bvalid) begin
                    axi_bvalid <= 1'b0;
                end
            end
        end
    end

    // axi_arready 생성 (변경 없음)
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
        end else begin
            if (~axi_arready && S_AXI_ARVALID) begin
                axi_arready <= 1'b1;
                axi_araddr  <= S_AXI_ARADDR;
            end else begin
                axi_arready <= 1'b0;
            end
        end
    end

    // axi_rvalid 생성 (변경 없음)
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_rvalid <= 0;
            axi_rresp  <= 0;
        end else begin
            if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b0;
            end else if (axi_rvalid && S_AXI_RREADY) begin
                axi_rvalid <= 1'b0;
            end
        end
    end

    // 레지스터 읽기 로직 (변경 없음)
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

    always @(*) begin
        case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
            2'h0   : reg_data_out <= slv_reg0;
            2'h1   : reg_data_out <= slv_reg1;
            2'h2   : reg_data_out <= slv_reg2;
            2'h3   : reg_data_out <= slv_reg3;
            default : reg_data_out <= 0;
        endcase
    end

    // 출력 레지스터 (변경 없음)
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_rdata <= 0;
        end else begin
            if (slv_reg_rden) begin
                axi_rdata <= reg_data_out;
            end
        end
    end

endmodule
