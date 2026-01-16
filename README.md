# SoC-AXI4-Lite-I2C-Master_Slave
## MicroBlaze 프로세서와 직접 설계한 AXI 기반 I2C IP를 활용하여, 두 FPGA 보드 간의 통신을 통해 카운터를 원격 제어하는 SoC 시스템 구현 프로젝트
<br>

## 프로젝트 개요 (Project Overview)

### 목표: FPGA Master-Slave 간 Custom I2C IP 통신 구현 및 Master 버튼 입력을 통한 Slave FND 원격 제어 
### 핵심 기술 : 
- Hardware : Xilinx FPGA (Basys3), Verilog HDL, AXI4-Lite Interface, Custom IP Design 
- Processor : MicroBlaze Soft Core Processor 
- Software : C Programming (Vitis IDE), Memory Mapped I/O 
- Protocol : I2C (Inter-Integrated Circuit) 2-wire Interface 

## System Architecture
<img width="997" height="265" alt="스크린샷 2026-01-13 104609" src="https://github.com/user-attachments/assets/d84697a8-86b1-4cb9-a4e3-5facbc2d7fa3" />
<br>

### 하드웨어 시스템 아키텍처 (Vivado Design)
#### A. Master Board 설계 (MicroBlaze 기반 SoC)
- MicroBlaze Processor : 시스템 메인 컨트롤러로서 C 어플리케이션 실행, 버튼 입력 처리 및 I2C 명령어 전달 
- AXI Interconnect & AXI4-Lite : CPU와 Custom IP 간 데이터 통신을 위한 버스 인터페이스 구축
- Custom IP (I2C_Master) :
- 기능 : CPU 명령(Start, Stop, Write) 수신 및 물리적 SCL, SDA 신호 생성 
- FSM 설계 : IDLE → START → DATA → ACK → STOP 순의 상태 천이를 통한 I2C 타이밍 제어 
- 레지스터 맵 : CR, TX_DATA, RX_DATA, SR 등을 주소에 매핑하여 S/W 제어 인터페이스 제공 
- AXI GPIO : 4개의 푸시 버튼(Up, Down, Left, Right) 입력 신호의 CPU 전달 

#### B. Slave Board 설계 (RTL Logic)
- I2C_Slave :
> Master의 SCL, SDA 신호 모니터링 및 Start/Stop 컨디션 감지 
> Slave Address(SLV_ADDR) 매칭 시 데이터 수신 및 내부 레지스터(slv_reg0~3) 저장 
> fndController : 수신된 8비트 데이터를 7-Segment Display(FND) 구동 신호로 변환 및 출력 
> btn_push_counter : Slave 자체 버튼 입력을 통한 FND 표시 레지스터 인덱스(sel) 변경 기능 구현 
<br>

### 소프트웨어 설계 (Vitis - C Application)
#### A. 구조체 및 주소 정의
- 제어 구조체 선언 : AXI 레지스터 오프셋(CMD, TX_DATA, RX_DATA, SR)에 맞춘 IIC_typedef 구조체 정의
- Memory Mapped I/O : Base Address(0x44a00000)를 포인터로 매핑하여 하드웨어 직접 제어

#### B. 메인 동작 알고리즘
- 초기화 : GPIO 및 I2C 통신 초기 설정 수행
- Polling & Debouncing :
> while(1) 루프를 통한 버튼 상태 지속적 모니터링
> prev_btn 변수 활용 Falling Edge 검출 및 usleep(10000)을 통한 디바운싱 처리
- 카운터 제어 로직 :
- BTNU : 카운터 값 증가 및 오버플로우 처리 
- BTND : 카운터 값 감소 및 언더플로우 처리 
- BTNL : 카운터 0으로 리셋 
- 데이터 전송 : 값 변경 시 send_single_data() 호출을 통한 Slave 전송

#### C. I2C 드라이버 함수 구현
- send_single_data : Start → Slave Address → Register Address → Data → Stop의 전체 트랜잭션 관리
- write_IIC : tx_data 레지스터 쓰기 및 WR_CM 명령 전달, SR 레지스터 Polling을 통한 전송 완료 대기
<br>

### 전체 동작 시나리오 (Operation Flow)
- 사용자 입력 : Master 보드의 BTNU(Up) 버튼 입력 
- S/W 처리 : C 프로그램에서 입력 감지, 카운터 연산 수행, 데이터 전송 함수 호출
- H/W 통신 (Master) : MicroBlaze가 I2C IP 제어, SCL/SDA 라인을 통해 패킷(Addr, Data) 직렬 전송 
- H/W 수신 (Slave) : I2C_Slave 모듈에서 주소 확인 및 slv_reg0 레지스터에 데이터 저장
- 출력 : fndController가 저장된 값을 읽어 FND에 숫자 표시 
<br>

### 프로젝트 핵심 성과 및 의의
- Full-Stack FPGA 설계: RTL IP 설계부터 Block Design 시스템 통합, Firmware 개발까지 임베디드 시스템 전 과정 수행 
- Custom IP 개발: 상용 IP 없이 I2C 프로토콜 분석을 바탕으로 FSM 기반 Master/Slave 모듈 직접 설계(RTL) 
- HW/SW Co-design: AXI4-Lite 인터페이스를 활용하여 S/W(C언어)가 H/W 레지스터를 제어하는 SoC 구조 구현 및 이해 
- 검증 및 신뢰성 확보: Vivado 시뮬레이션 파형 검증 및 실제 보드 테스트를 통한 기능 동작 확인
<br>

## 특징
### AXI4-Lite
#### - AXI4-Lite는 ARM의 AMBA AXI4 규격 중 간단한 제어/상태 레지스터 접근용 경량 인터페이스입니다. 복잡한 데이터 버스트 전송이 필요 없는 경우 사용
> AXI나 AHB는 GPIO, UART, FND, TIMER 같은 저속 제어 장치에는 불필요하게 복잡, 전력 소모 ↑
> -> SoC 전체 성능과 효율을 높이기 위해 저속 장치들은 APB 버스로 연결

#### 🧠 프로토콜 구조
📥 읽기 경로 (Read)
- ARADDR (주소)
- ARVALID / ARREADY
- RDATA (읽은 데이터)
- RRESP (응답 상태)
- RVALID / RREADY

📤 쓰기 경로 (Write)
- AWADDR (주소)
- AWVALID / AWREADY
- WDATA (쓰기 데이터)
- WSTRB (바이트 스트로브)
- WVALID / WREADY
- BRESP (응답)
- BVALID / BREADY

### I2C(Inter-Integrated Circuit)
- 필립스에서 개발한 직렬 통신 프로토콜로, 두 개의 와이어(SDA, SCL)를 통해 통신하는 동기식 다중 마스터/슬레이브 통신 방식
- 직렬 통신 : 한 번에 한 비트씩 데이터를 전송
- 2선 통신 : 데이터 전송 선(SDA)와 클럭 신호 선(SCL) 두 개의 선으로 이루어짐
- 반이중(Half Duplex) 통신 : 마스터 → 슬레이브 혹은 슬레이브 → 마스터로 한 번에 한 방향으로만 통신이 가능

#### - 시리얼 통신
<img width="961" height="325" alt="image" src="https://github.com/user-attachments/assets/53e0bc87-ccf3-429c-b342-97bc08594e94" />
<br>

