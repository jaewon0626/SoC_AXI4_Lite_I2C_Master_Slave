onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib i2c_cpu_opt

do {wave.do}

view wave
view structure
view signals

do {i2c_cpu.udo}

run -all

quit -force
