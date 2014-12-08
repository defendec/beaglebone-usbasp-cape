# make sure you have run kana-setup-pins.sh
echo "selecting mux port 1"

# set to port 1
echo 0 > /sys/class/gpio/gpio47/value
echo 0 > /sys/class/gpio/gpio22/value
echo 0 > /sys/class/gpio/gpio61/value
echo 0 > /sys/class/gpio/gpio27/value
