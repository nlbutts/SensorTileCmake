target remote 10.0.2.2:2331
monitor reset
monitor flash device stm32l476jg
monitor flash breakpoints = 1
load
b main
monitor reset
c
