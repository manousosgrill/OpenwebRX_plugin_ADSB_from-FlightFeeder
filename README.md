Technical Report — ADS-B / OpenWebRX+ Integration and Debugging

Date: 6 September 2026
Platform: Debian / OpenWebRX+ / dump1090-fa
Subject: ADS-B aircraft reception, processing, JSON synchronization and OpenWebRX+ map visualization

1. Objective

The objective of the work was to integrate an ADS-B aircraft data source with OpenWebRX+, display aircraft on the web map, and troubleshoot the aircraft-processing chain.

The work progressed from testing the ADS-B network feed, through dump1090-fa, aircraft JSON generation and synchronization, to modifications inside the OpenWebRX/csdr aircraft-processing code.

2. ADS-B Receiver and dump1090-fa

The installed ADS-B decoder was identified as:

/usr/bin/dump1090-fa

The running configuration was observed as:

/usr/bin/dump1090-fa \
    --net-only \
    --net-bi-port 30104 \
    --net-bo-port 30005 \
    --net-sbs-port 30003

The relevant network interfaces were therefore:

Port	Function
30104	Beast input
30005	Beast output
30003	SBS output
3. Beast Feed Testing

Two network ADS-B sources were tested.

Failed source
192.168.10.213:30005

This source did not provide the required ADS-B Beast data.

Working source
192.168.10.170:30005

This source was successfully identified as providing a usable Beast ADS-B feed.

This was an important step because it established that the aircraft data itself was available and that the problem was not simply an absence of ADS-B reception.

4. Aircraft JSON

The aircraft data was investigated through the aircraft.json mechanism.

Two locations were involved:

/tmp/dump1090/aircraft.json

and:

/tmp/owrx-adsb/aircraft.json

The JSON files were inspected and parsed to determine whether actual aircraft records were present.

This established that aircraft data was being generated/available independently of the OpenWebRX map display.

5. aircraft-sync.sh

A synchronization script was created/used:

aircraft-sync.sh

Its purpose was to retrieve/synchronize the aircraft JSON data into a location accessible to the OpenWebRX ADS-B overlay.

The basic data flow became:

dump1090-fa
      │
      ↓
 aircraft data
      │
      ↓
aircraft-sync.sh
      │
      ↓
aircraft.json
      │
      ↓
OpenWebRX+ ADS-B
      │
      ↓
Web map

This synchronization layer became particularly important during troubleshooting because aircraft continued to appear on the OpenWebRX map even after other ADS-B changes were made.

6. OpenWebRX Aircraft Source Code

A significant part of the work was performed directly inside the installed Python packages.

The two important source files were:

/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py

and:

/usr/lib/python3/dist-packages/csdr/chain/aircraft.py

These files should be considered modified ADS-B source files in the project documentation.

They are more significant than the temporary JSON files because they participate directly in the aircraft processing/decoding chain.

7. owrx/aircraft/__init__.py

File:

/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py

This is part of the OpenWebRX aircraft functionality.

During the ADS-B investigation we examined and modified the aircraft-processing logic in this module.

The purpose was to control how aircraft data was handled by OpenWebRX+ and to troubleshoot the connection between the received aircraft information and the web presentation.

8. csdr/chain/aircraft.py

File:

/usr/lib/python3/dist-packages/csdr/chain/aircraft.py

This file was also modified as part of the ADS-B processing investigation.

It belongs to the csdr aircraft-processing chain and therefore sits at a lower processing level than the OpenWebRX web interface.

The work on this file was important because the ADS-B path was not simply a browser-side problem; aircraft processing was also occurring inside the installed Python/csdr software.

9. Runtime Directory Investigation

We specifically checked:

ls -lah /run/dump1090-fa/

The result was:

ls: cannot access '/run/dump1090-fa/': No such file or directory

Therefore, on this installation there was no active /run/dump1090-fa/ directory containing the expected aircraft JSON.

This ruled out the assumption that OpenWebRX was necessarily reading:

/run/dump1090-fa/aircraft.json

and led us to investigate the alternative /tmp locations and synchronization mechanism.

10. OpenWebRX Configuration

The main OpenWebRX configuration file investigated was:

/etc/openwebrx/openwebrx.conf

This was examined in connection with the ADS-B integration and receiver configuration.

It should currently be classified in the report as:

Inspected / investigated

rather than automatically being listed as modified unless the exact final configuration changes are verified.

11. ADS-B Map Visualization

The final goal was to display aircraft on the OpenWebRX+ map.

The intended architecture was:

                    RTL-SDR
                       │
                       ↓
                 dump1090-fa
                       │
                       ↓
                Beast / SBS data
                       │
                       ↓
             Aircraft processing
                       │
          ┌────────────┴────────────┐
          ↓                         ↓
owrx/aircraft/__init__.py    csdr/chain/aircraft.py
          │                         │
          └────────────┬────────────┘
                       ↓
                 aircraft data
                       │
                       ↓
                aircraft.json
                       │
                       ↓
              OpenWebRX+ overlay
                       │
                       ↓
                  Leaflet map

The aircraft marker visualization was also investigated, including aircraft heading/orientation so that an aircraft icon can represent its actual flight direction.

12. Main Problem Encountered

The major issue at the latest stage was:

Aircraft continued to appear on the OpenWebRX+ map even after ADS-B-related changes were made.

The investigation showed that this was not necessarily caused by dump1090-fa alone.

There were multiple possible points in the data path:

dump1090-fa
     ↓
aircraft processing
     ↓
aircraft-sync.sh
     ↓
/tmp/dump1090/aircraft.json
     ↓
/tmp/owrx-adsb/aircraft.json
     ↓
OpenWebRX ADS-B overlay
     ↓
browser

Consequently, the next stage was to identify which component was still producing aircraft data and which component was still consuming it.

13. Files Modified / Created

The ADS-B project file list should therefore be documented as follows.

Confirmed modified/created
/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py

/usr/lib/python3/dist-packages/csdr/chain/aircraft.py

aircraft-sync.sh

/tmp/dump1090/aircraft.json

/tmp/owrx-adsb/aircraft.json
Investigated
/etc/openwebrx/openwebrx.conf

/usr/bin/dump1090-fa

/run/dump1090-fa/

The distinction is important because the first group contains the files involved in the actual modifications/data workflow, while the second group contains system components that we inspected while diagnosing the problem.

14. Troubleshooting Methodology

The investigation used several layers rather than assuming the problem was in one component:

Network connectivity
Tested Beast feeds.
dump1090-fa
Verified executable and network parameters.
Aircraft JSON
Located and inspected JSON data.
Synchronization
Investigated aircraft-sync.sh.
OpenWebRX
Examined OpenWebRX configuration.
Python source
Modified owrx/aircraft/__init__.py.
csdr processing
Modified csdr/chain/aircraft.py.
Web map
Investigated aircraft display and marker behavior.
Runtime verification
Used Linux process/service inspection and JSON testing.
15. Current Status

At the end of the latest ADS-B work:

Working/confirmed
dump1090-fa is installed.
ADS-B Beast networking was investigated.
192.168.10.170:30005 was confirmed as a working ADS-B source.
Aircraft JSON data was successfully located.
Aircraft JSON contained actual aircraft data.
ADS-B processing code in OpenWebRX/csdr was identified and modified.
Aircraft synchronization was implemented/investigated.
OpenWebRX aircraft-map visualization was operational.
Remaining issue

The remaining problem was determining why aircraft data was still reaching the OpenWebRX map when the intention was to stop/remove that feed.

The next step is therefore not another blind modification, but tracing the complete active path:

WHO CREATES aircraft.json?
        ↓
WHO MODIFIES/COPIES aircraft.json?
        ↓
WHO SERVES aircraft.json?
        ↓
WHO REQUESTS aircraft.json?
        ↓
WHO CREATES THE AIRCRAFT MARKERS?
16. Important Recommendation

Because we modified files directly under:

/usr/lib/python3/dist-packages/

the changes are vulnerable to being overwritten by a future OpenWebRX/package upgrade.

Once the ADS-B implementation is finalized, the modifications should ideally be saved as a patch/backup so that the working configuration can be restored after an upgrade.

Final ADS-B project file set
/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py
/usr/lib/python3/dist-packages/csdr/chain/aircraft.py
aircraft-sync.sh
/tmp/dump1090/aircraft.json
/tmp/owrx-adsb/aircraft.json

