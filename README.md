Cape for BeagleBone that can be used for programming and logging AVR devices using usbasp connector.

# Known issues
Revision A uses pins that are used by BeagleBone emmc interface. Therefore following cut and paste changes must be made:

    P8 B23 -> P8 B19 [GPIO0_22]
    P8 B25 -> P8 B26 [GPIO1_29]
    P8 B5  -> P8 B7  [GPIO2_2 ]
    
MISO and MOSI pins are swapped, it can be corrected on software side.
TODO: how to do it.

# License
This work is licensed under CC BY-SA 3.0 http://creativecommons.org/licenses/by-sa/3.0/
