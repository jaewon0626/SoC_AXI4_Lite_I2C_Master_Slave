`timescale 1ns / 1ps

module I2C_MASTER (
    //global signal
    input  logic       clk,
    input  logic       reset,
    //input signal
    input  logic [7:0] tx_data,
    input  logic       i2c_start,
    input  logic       i2c_en,
    input  logic       stop,
    //output signal
    output logic       tx_done,
    output logic       ready,
    output logic [7:0] rx_data,
    //output logic [4:0] mst_state,
    //ic2 signal
    output logic       SCL,
    inout  logic       SDA
);

    localparam SCL_QUARTER_PERIOD_CLKS = 249;  // 2.5us (250 cycles)
    localparam SCL_HALF_PERIOD_CLKS = 499;  // 5.0us (500 cycles)

    typedef enum {
        IDLE,
        START1,
        START2,
        DATA_WRITE1,
        DATA_WRITE2,
        DATA_WRITE3,
        DATA_WRITE4,
        DATA_READ1,
        DATA_READ2,
        DATA_READ3,
        DATA_READ4,
        ACK_WRITE1,
        ACK_WRITE2,
        ACK_WRITE3,
        ACK_WRITE4,
        ACK_READ1,
        ACK_READ2,
        ACK_READ3,
        ACK_READ4,
        HOLD_AFTER_WRITE,
        HOLD_AFTER_READ,
        STOP1,
        STOP2
    } state_e;


    state_e state, state_next;
    logic [10:0] clk_counter_reg, clk_counter_next;
    logic [7:0] temp_tx_data_reg, temp_tx_data_next;
    logic [7:0] temp_rx_data_reg, temp_rx_data_next;  //실시간 rx
    logic [7:0] read_return_reg, read_return_next; //read 작업이 끝날때만 rx_temp를 저장하는 공간
    logic [3:0] bit_counter_reg, bit_counter_next;
    logic SCL_reg, SCL_next;
    logic tx_done_reg, tx_done_next;
    logic ready_reg, ready_next;
    logic wr_rd_reg, wr_rd_next;
    logic addr_phase_reg, addr_phase_next;

    // --- 수정된 '스티키 빗' 래치 ---
    logic stop_latch_reg;  // stop 신호 래치
    logic restart_latch_reg;  // i2c_start(Repeated Start) 신호 래치

    //SDA inout 
    logic sda_out_reg, sda_out_next;
    logic sda_out_en_reg, sda_out_en_next;
    assign SDA = (sda_out_en_reg) ? sda_out_reg : 1'bz;


    assign mst_state = state;
    assign SCL = SCL_reg;
    assign rx_data = read_return_reg;
    assign tx_done = tx_done_reg;
    assign ready = ready_reg;


    // --- stop_latch_reg 로직 ---
    // 'stop'이 1이 되면 래치하고, 'STOP1' 상태로 가면 0으로 클리어됩니다.
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            stop_latch_reg <= 1'b0;
        end else if (state_next == STOP1) begin // STOP 상태 진입 시 클리어
            stop_latch_reg <= 1'b0;
        end else if (stop == 1'b1) begin  // stop이 1이면 래치
            stop_latch_reg <= 1'b1;
        end
    end

    // --- restart_latch_reg 로직 ---
    // 'IDLE'이 아닐 때 'i2c_start'가 1이 되면 래치하고, 'START1' 상태로 가면 0으로 클리어됩니다.
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            restart_latch_reg <= 1'b0;
        end else if (state_next == START1) begin // START1 상태 진입 시 클리어
            restart_latch_reg <= 1'b0;
        end else if (state != IDLE && i2c_start == 1'b1) begin // IDLE이 아닐 때 i2c_start가 1이면 래치
            restart_latch_reg <= 1'b1;
        end
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            clk_counter_reg <= 0;
            SCL_reg <= 1;
            sda_out_en_reg <= 0;
            sda_out_reg <= 1;
            temp_tx_data_reg <= 0;
            temp_rx_data_reg <= 0;
            read_return_reg <= 0;
            bit_counter_reg <= 0;
            tx_done_reg <= 0;
            ready_reg <= 0;
            wr_rd_reg <= 0;
            addr_phase_reg <= 1'b1;
            // stop_latch_reg <= 1'b0; // 별도 로직으로 분리
            // restart_latch_reg <= 1'b0; // 별도 로직으로 분리
        end else begin
            state <= state_next;
            clk_counter_reg <= clk_counter_next;
            SCL_reg <= SCL_next;
            sda_out_en_reg <= sda_out_en_next;
            sda_out_reg <= sda_out_next;
            temp_tx_data_reg <= temp_tx_data_next;
            temp_rx_data_reg <= temp_rx_data_next;
            read_return_reg <= read_return_next;
            bit_counter_reg <= bit_counter_next;
            tx_done_reg <= tx_done_next;
            ready_reg <= ready_next;
            wr_rd_reg <= wr_rd_next;
            addr_phase_reg <= addr_phase_next;
        end
    end

    always @(*) begin
        state_next = state;
        clk_counter_next = clk_counter_reg;
        SCL_next = SCL_reg;
        sda_out_en_next = sda_out_en_reg;
        sda_out_next = sda_out_reg;
        temp_tx_data_next = temp_tx_data_reg;
        temp_rx_data_next = temp_rx_data_reg;
        read_return_next = read_return_reg;
        bit_counter_next = bit_counter_reg;
        tx_done_next = 0;
        ready_next = 0;
        addr_phase_next   = addr_phase_reg;  //주소단계인지, 데이터단계인지 구분
        wr_rd_next = wr_rd_reg;  //read인지, write인지 구분

        case (state)
            IDLE: begin  //0
                SCL_next         = 1;
                sda_out_en_next  = 0;
                sda_out_next     = 1;
                clk_counter_next = 0;
                ready_next       = i2c_en;
                if (i2c_start && i2c_en) begin // IDLE에서는 'i2c_start' 레벨 감지로 시작
                    ready_next       = 0;
                    bit_counter_next = 0;
                    state_next       = START1;
                end else begin
                    addr_phase_next = 1'b1; // IDLE 상태에서는 항상 다음을 주소 단계로 리셋
                end
            end
            START1: begin  //1
                if (SCL_reg == 0) begin // 1. HOLD 상태(SCL=0)에서 점프한 경우
                    SCL_next = 1;  // SCL을 1로
                    sda_out_en_next = 1;
                    sda_out_next = 1;  // SDA도 1로 (Repeated Start 준비)
                    clk_counter_next = 0;  // 카운터 리셋
                    state_next       = START1; // SCL이 1이 될 때까지 START1에 머무름
                end else begin // 2. IDLE 상태(SCL=1)에서 왔거나, SCL이 1이 된 후
                    SCL_next = 1;  // SCL=1 유지
                    sda_out_en_next = 1;
                    sda_out_next = 0;  // SDA=0 (Start 신호 생성)

                    // --- 데이터 래치 로직 (공통) ---
                    temp_tx_data_next = tx_data; // 시작 시점에 tx_data 래치
                    if (addr_phase_reg == 1'b1) begin  // 주소 단계인지 확인
                        wr_rd_next = tx_data[0];  // wr인지 re인지 판단
                    end

                    if (clk_counter_reg == SCL_HALF_PERIOD_CLKS) begin
                        state_next       = START2;
                        clk_counter_next = 0;
                    end else begin
                        clk_counter_next = clk_counter_reg + 1;
                    end
                end
            end
            START2: begin  //2
                SCL_next        = 0;
                sda_out_en_next = 1;
                sda_out_next    = 0;
                if (clk_counter_reg == SCL_HALF_PERIOD_CLKS) begin
                    state_next       = DATA_WRITE1;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            DATA_WRITE1: begin  //3
                SCL_next        = 0;
                sda_out_en_next = 1;
                sda_out_next    = temp_tx_data_reg[7];
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = DATA_WRITE2;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            DATA_WRITE2: begin  //4
                SCL_next        = 1;
                sda_out_en_next = 1;
                sda_out_next    = temp_tx_data_reg[7];
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = DATA_WRITE3;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            DATA_WRITE3: begin  //5
                SCL_next        = 1;
                sda_out_en_next = 1;
                sda_out_next    = temp_tx_data_reg[7];
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = DATA_WRITE4;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            DATA_WRITE4: begin  //6
                SCL_next        = 0;
                sda_out_en_next = 1;
                sda_out_next    = temp_tx_data_reg[7];
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    clk_counter_next = 0;
                    if (bit_counter_reg == 7) begin
                        state_next = ACK_WRITE1;
                        temp_tx_data_next = 0;
                    end else begin
                        bit_counter_next = bit_counter_reg + 1;
                        temp_tx_data_next = temp_tx_data_reg << 1;  //왼쪽 1비트 시프트
                        state_next = DATA_WRITE1;
                        clk_counter_next = 0;
                    end
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end

            DATA_READ1: begin  //7
                SCL_next        = 0;
                sda_out_en_next = 0;
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = DATA_READ2;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            DATA_READ2: begin  //8
                SCL_next        = 1;
                sda_out_en_next = 0;
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = DATA_READ3;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            DATA_READ3: begin  //9
                SCL_next        = 1;
                sda_out_en_next = 0;
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next        = DATA_READ4;
                    clk_counter_next  = 0;
                    temp_rx_data_next = (temp_rx_data_reg << 1) | SDA;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            DATA_READ4: begin  //10
                SCL_next        = 0;
                sda_out_en_next = 0;
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    clk_counter_next = 0;
                    if (bit_counter_reg == 7) begin
                        state_next = ACK_READ1;
                    end else begin
                        bit_counter_next = bit_counter_reg + 1;
                        state_next       = DATA_READ1;
                        clk_counter_next = 0;
                    end
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            ACK_WRITE1: begin  //11
                SCL_next        = 0;
                sda_out_en_next = 0;
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = ACK_WRITE2;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            ACK_WRITE2: begin  //12
                SCL_next        = 1;
                sda_out_en_next = 0;
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    temp_rx_data_next[0] = SDA;  //slave로부터 ACK값 읽기
                    state_next = ACK_WRITE3;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            ACK_WRITE3: begin  //13
                SCL_next        = 1;
                sda_out_en_next = 0;
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = ACK_WRITE4;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            ACK_WRITE4: begin  //14
                SCL_next = 0;
                sda_out_en_next = 0;
                temp_rx_data_next = 0;  // ACK 읽은 후 rx_data 클리어
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = HOLD_AFTER_WRITE;
                    tx_done_next     = 1;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            ACK_READ1: begin  //15
                SCL_next = 0;
                sda_out_en_next = 1;
                sda_out_next    = stop_latch_reg; // 래치된 값 사용
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = ACK_READ2;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            ACK_READ2: begin  //16
                SCL_next = 1;
                sda_out_en_next = 1;
                sda_out_next    = stop_latch_reg; // 래치된 값 사용
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = ACK_READ3;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            ACK_READ3: begin  //17
                read_return_next = temp_rx_data_reg;
                SCL_next         = 1;
                sda_out_en_next  = 1;
                sda_out_next     = stop_latch_reg;  // 래치된 값 사용
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    state_next       = ACK_READ4;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            ACK_READ4: begin  //18
                SCL_next = 0;
                sda_out_en_next = 1;
                sda_out_next    = stop_latch_reg; // 래치된 값 사용
                if (clk_counter_reg == SCL_QUARTER_PERIOD_CLKS) begin
                    tx_done_next = 1;  // Read 완료 시점에 tx_done 발생
                    state_next = HOLD_AFTER_READ;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            HOLD_AFTER_WRITE: begin  //19
                SCL_next        = 0;
                sda_out_en_next = 0;
                if (temp_rx_data_reg[0] == 1'b1) begin  //slave가 NACK 전송
                    sda_out_en_next = 1;
                    sda_out_next = 0;
                    state_next = STOP1;
                    addr_phase_next = 1'b1;
                end else begin  // 슬레이브가 ACK 전송

                    // --- 1. Repeated Start 확인 (래치 값 사용) ---
                    if (restart_latch_reg) begin
                        state_next       = START1;
                        clk_counter_next = 0;
                        addr_phase_next  = 1'b1;  // 다음은 주소 단계
                        bit_counter_next = 0;

                        // --- 2. Stop 확인 (데이터 단계였을 경우, 래치 값 사용) ---
                    end else if (addr_phase_reg == 1'b0 && stop_latch_reg == 1'b1) begin // 마스터가 중지를 원함
                        sda_out_en_next = 1;
                        sda_out_next    = 0;
                        state_next      = STOP1;
                        addr_phase_next = 1'b1;

                        // --- 3. 주소 단계였을 경우 (R/W 분기) ---
                    end else if (addr_phase_reg == 1'b1) begin // 주소 단계였을 경우
                        if (wr_rd_reg == 1'b0) begin  //write
                            addr_phase_next = 1'b0; // 데이터 단계로 변경
                            temp_tx_data_next = tx_data;
                            state_next = DATA_WRITE1;
                            bit_counter_next = 0;
                        end else begin  //read
                            addr_phase_next = 1'b0; // 데이터 단계로 변경
                            bit_counter_next = 0;
                            temp_rx_data_next = 0;
                            state_next = DATA_READ1;
                        end

                        // --- 4. 데이터 단계였을 경우 (계속 쓰기) ---
                    end else begin // 데이터 단계였을 경우 (멀티바이트 쓰기)
                        temp_tx_data_next = tx_data; // 다음 보낼 데이터 로드
                        state_next = DATA_WRITE1;
                        bit_counter_next = 0;
                    end
                end
            end
            HOLD_AFTER_READ: begin  // 20
                SCL_next = 0;
                sda_out_en_next = 1;
                sda_out_next    = stop_latch_reg; // ACK/NACK 값 유지

                // --- 1. Repeated Start 확인 (래치 값 사용) ---
                if (restart_latch_reg) begin
                    state_next       = START1;
                    clk_counter_next = 0;
                    addr_phase_next  = 1'b1;  // 다음은 주소 단계
                    bit_counter_next = 0;

                    // --- 2. NACK을 보냈으므로 STOP ---
                end else if (stop_latch_reg == 1'b1) begin // NACK을 보냈으므로 STOP
                    sda_out_next = 0;  // STOP 신호를 위해 SDA low 준비
                    state_next = STOP1;
                    addr_phase_next = 1'b1;

                    // --- 3. ACK을 보냈으므로 다음 바이트 읽기 ---
                end else begin // ACK을 보냈으므로 다음 바이트 읽기
                    bit_counter_next  = 0;
                    temp_rx_data_next = 0;
                    state_next        = DATA_READ1;
                    addr_phase_next   = 1'b0;  // 데이터 단계 유지
                end
            end
            STOP1: begin  //21
                SCL_next        = 1;
                sda_out_en_next = 1;
                sda_out_next    = 0;
                if (clk_counter_reg == SCL_HALF_PERIOD_CLKS) begin
                    state_next       = STOP2;
                    clk_counter_next = 0;
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            STOP2: begin  //22
                SCL_next        = 1;
                sda_out_en_next = 1;
                sda_out_next    = 1;
                if (clk_counter_reg == SCL_HALF_PERIOD_CLKS) begin
                    state_next = IDLE;
                    clk_counter_next = 0;
                    //tx_done_next = 1; // STOP이 완료될 때 tx_done 발생
                    wr_rd_next = 0;
                    addr_phase_next  = 1'b1; // 트랜잭션 완료 후 다음은 주소 단계
                end else begin
                    clk_counter_next = clk_counter_reg + 1;
                end
            end
            default: begin
                state_next = IDLE;
            end
        endcase
    end
endmodule
