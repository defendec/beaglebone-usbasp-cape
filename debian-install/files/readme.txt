using avrdude
=============

    root@koerkana0 13:43:25 :~# kana-select-port-1.sh; /usr/local/bin/avrdude -clinuxspi1 -P/dev/spidev1.0 -U hfuse:w:0xd8:m -pm128rfa1 -U efuse:w:0xf0:m -U flash:w:/tmp/main.srec:a
    root@koerkana0 13:43:25 :~# kana-select-port-2.sh; /usr/local/bin/avrdude -clinuxspi2 -P/dev/spidev1.0 -U hfuse:w:0xd8:m -pm128rfa1 -U efuse:w:0xf0:m -U flash:w:/tmp/main.srec:a


using printf-uart-nanomsg
=========================

    the number is ttyO4 port number. 4 here.

    systemctl enable/disable/start/stop/status printf-uart-nanomsg@1.service
    systemctl enable/disable/start/stop/status printf-uart-nanomsg@4.service
