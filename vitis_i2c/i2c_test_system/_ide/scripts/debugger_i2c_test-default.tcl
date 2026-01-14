# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: D:\working\systemverilog\2025_11_14_I2C_IP_project\vitis_i2c\i2c_test_system\_ide\scripts\debugger_i2c_test-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source D:\working\systemverilog\2025_11_14_I2C_IP_project\vitis_i2c\i2c_test_system\_ide\scripts\debugger_i2c_test-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Basys3 210183BE10F0A" && level==0 && jtag_device_ctx=="jsn-Basys3-210183BE10F0A-0362d093-0"}
fpga -file D:/working/systemverilog/2025_11_14_I2C_IP_project/vitis_i2c/i2c_test/_ide/bitstream/i2c_cpu_wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw D:/working/systemverilog/2025_11_14_I2C_IP_project/vitis_i2c/i2c_cpu_wrapper/export/i2c_cpu_wrapper/hw/i2c_cpu_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow D:/working/systemverilog/2025_11_14_I2C_IP_project/vitis_i2c/i2c_test/Debug/i2c_test.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
