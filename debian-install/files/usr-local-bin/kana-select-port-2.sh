# make sure you have run kana-setup-pins.sh
echo "selecting mux port 2"

# set to port 2
echo 0 > /sys/class/gpio/gpio47/value
echo 0 > /sys/class/gpio/gpio22/value
echo 1 > /sys/class/gpio/gpio61/value
echo 0 > /sys/class/gpio/gpio27/value
