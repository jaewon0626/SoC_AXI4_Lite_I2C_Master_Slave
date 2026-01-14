# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct D:\working\systemverilog\2025_11_14_I2C_IP_project\vitis_i2c\i2c_cpu_wrapper\platform.tcl
# 
# OR launch xsct and run below command.
# source D:\working\systemverilog\2025_11_14_I2C_IP_project\vitis_i2c\i2c_cpu_wrapper\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {i2c_cpu_wrapper}\
-hw {D:\working\systemverilog\2025_11_14_I2C_IP_project\vitis_i2c\i2c_cpu_wrapper.xsa}\
-fsbl-target {psu_cortexa53_0} -out {D:/working/systemverilog/2025_11_14_I2C_IP_project/vitis_i2c}

platform write
domain create -name {standalone_microblaze_0} -display-name {standalone_microblaze_0} -os {standalone} -proc {microblaze_0} -runtime {cpp} -arch {32-bit} -support-app {empty_application}
platform generate -domains 
platform active {i2c_cpu_wrapper}
platform generate -quick
platform generate
