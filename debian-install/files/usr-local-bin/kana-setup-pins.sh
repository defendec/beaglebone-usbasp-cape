# enable spi muxer port selection pins

# ----- 1OE 1_15
echo 47 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio47/direction

# ----- 2OE EHRPWM2A gpio0[22]
echo 22 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio22/direction

# ----- S0 1_29
echo 61 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio61/direction

# ----- S1 0_27
echo 27 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio27/direction

# by default, select port 1
echo 0 > /sys/class/gpio/gpio47/value
echo 0 > /sys/class/gpio/gpio22/value
echo 0 > /sys/class/gpio/gpio61/value
echo 0 > /sys/class/gpio/gpio27/value

# reset pins

# 1_28 for device 1 /sys/class/gpio/gpio60
#  1_2 for device 2 /sys/class/gpio/gpio34
