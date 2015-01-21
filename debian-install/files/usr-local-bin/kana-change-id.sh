if (($# != 1)); then
	echo "Change autossh port and hostname."
	echo "Reverse ssh port will be 15000+kana_num and hostname will be koerkana+kana_num (ex: 150007, koerkana7)"
	echo "DON'T USE ON LIVE ON-THE-FIELD SYSTEMS! might lose autossh connection."
	echo ""
	echo "Usage: kana-change-id.sh kana_num"
	echo "       kana-change-id.sh 1"
	exit 1
fi

REVERSE_PORT=$((${1} + 15000))
HOSTNAME="koerkana${1}"

echo "Using ssh reverse tunnel port $REVERSE_PORT and hostname $HOSTNAME"

hostnamectl set-hostname ${HOSTNAME}
systemctl restart avahi-daemon

systemctl disable autossh@.service
systemctl stop autossh@*

systemctl enable autossh@${REVERSE_PORT}.service
systemctl start autossh@${REVERSE_PORT}.service
