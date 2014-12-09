# enable spi muxer port selection pins

# ----- 1OE : P8_15 GPIO1_15
echo 47 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio47/direction

# ----- 2OE : P8_19 EHRPWM2A
echo 22 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio22/direction

# ----- S0  : P8_26 GPIO1_29
echo 61 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio61/direction

# ----- S1  : P8_17 GPIO0_27
echo 27 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio27/direction

# select port 1 by default now that the muxer gpio access is enabled,
kana-select-port-1.sh

# enable reset pins.
#
# note that this is not necessary for avrdude, but is needed if we want to
# reset the device using echo.
#
# P9_12 GPIO1_28 /sys/class/gpio/gpio60 for device 1
# P8_07   TIMER4 /sys/class/gpio/gpio66 for device 2

echo 60 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio60/direction
echo 1 > /sys/class/gpio/gpio60/value

echo 66 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio66/direction
echo 1 > /sys/class/gpio/gpio66/value
