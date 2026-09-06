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


















# Technical Report

## OpenWebRX+ ADS-B Integration, Aircraft Synchronization and Aircraft Map Modifications

**System:** OpenWebRX+ / Debian
**Date:** September 6, 2026
**Subject:** ADS-B aircraft reception, synchronization, processing and display integration

---

## 1. Objective

The objective of the work was to integrate and troubleshoot ADS-B aircraft data with the OpenWebRX+ installation.

The work included:

* Establishing the correct ADS-B data source.
* Testing Beast protocol connections.
* Identifying the working `dump1090-fa` instance.
* Synchronizing aircraft data into a JSON file accessible by OpenWebRX+.
* Modifying the OpenWebRX+ aircraft processing code.
* Modifying the CSDR aircraft processing chain.
* Modifying the OpenWebRX+ map JavaScript.
* Investigating aircraft position, heading and map display behaviour.
* Creating a systemd service for continuous aircraft JSON synchronization.
* Investigating why aircraft continued to appear on the map after changes to the JSON data.

---

# 2. ADS-B Data Source Investigation

Several ADS-B Beast TCP sources were tested.

The following source was found to be working:

**192.168.10.170:30005**

A second source:

**192.168.10.213:30005**

was tested but did not provide the expected ADS-B Beast data.

The system also contains:

```text
/usr/bin/dump1090-fa
```

which was identified as the installed `dump1090-fa` executable.

The `dump1090-fa` network configuration was investigated, including Beast and other network output ports.

---

# 3. Aircraft JSON Data

The aircraft data was investigated through JSON files.

The main files used during the troubleshooting were:

```text
/tmp/dump1090/aircraft.json
/tmp/owrx-adsb/aircraft.json
```

These files contain the aircraft information used by the ADS-B/map system.

The JSON contents were examined to determine:

* Number of aircraft being reported.
* Aircraft ICAO identifiers.
* Position information.
* Altitude.
* Ground speed.
* Track/heading.
* Other aircraft fields.
* Whether aircraft remained present in the data after synchronization.

An external SkyAware aircraft JSON endpoint was also tested and returned HTTP 200 with valid JSON content.

This confirmed that aircraft data was still being generated and served independently of the OpenWebRX map display.

---

# 4. Aircraft Synchronization Script

A dedicated synchronization script was created:

```text
/usr/local/bin/aircraft-sync.sh
```

The purpose of the script is to obtain aircraft data and place/synchronize it into the location expected by the OpenWebRX+ ADS-B integration.

The script was created or modified on:

**September 6, 2026 at 13:51:51**

The synchronization mechanism was introduced to separate the aircraft data source from the OpenWebRX+ aircraft display/processing logic.

---

# 5. Systemd Aircraft Synchronization Service

A systemd service was created:

```text
/etc/systemd/system/aircraft-sync.service
```

Timestamp:

**September 6, 2026 at 13:52:18**

The service is intended to execute the aircraft synchronization process automatically rather than requiring manual execution of the synchronization script.

The resulting architecture is therefore approximately:

```text
ADS-B Receiver
      │
      ▼
 dump1090-fa
      │
      ▼
aircraft JSON
      │
      ▼
aircraft-sync.sh
      │
      ▼
/tmp/owrx-adsb/aircraft.json
      │
      ▼
OpenWebRX+ ADS-B processing
      │
      ▼
OpenWebRX+ Map
```

---

# 6. OpenWebRX+ Aircraft Backend Modification

The OpenWebRX+ aircraft module was modified:

```text
/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py
```

A backup was created before modification:

```text
/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py.bak-adsb
```

The timestamps confirm:

```text
14:09:28  backup created
14:09:57  aircraft/__init__.py modified
14:10:27  Python bytecode regenerated
```

This modification is part of the ADS-B processing investigation and was intended to alter/control how OpenWebRX+ handles aircraft information.

---

# 7. OpenWebRX+ Main Application Modification

The following OpenWebRX+ file was also modified:

```text
/usr/lib/python3/dist-packages/owrx/__main__.py
```

Timestamp:

**September 6, 2026 at 14:13:15**

The corresponding Python bytecode was subsequently regenerated:

```text
/usr/lib/python3/dist-packages/owrx/__pycache__/__main__.cpython-311.pyc
```

at:

**14:13:30**

Because the filesystem timestamps confirm that this file was modified during the ADS-B troubleshooting session, it is included as part of the technical ADS-B work.

The exact functional difference should be determined with a source diff if a precise line-by-line change log is required.

---

# 8. CSDR Aircraft Processing Chain Modification

The CSDR aircraft processing module was modified:

```text
/usr/lib/python3/dist-packages/csdr/chain/aircraft.py
```

Timestamp:

**September 6, 2026 at 14:22:38**

Python regenerated the corresponding bytecode:

```text
/usr/lib/python3/dist-packages/csdr/chain/__pycache__/aircraft.cpython-311.pyc
```

at:

**14:22:54**

This confirms that the CSDR aircraft processing chain was actively modified and then loaded by Python during the ADS-B troubleshooting.

This file is therefore a confirmed component of the ADS-B modifications.

---

# 9. OpenWebRX+ Map JavaScript Modification

The frontend aircraft/map code was subsequently modified:

```text
/usr/lib/python3/dist-packages/htdocs/plugins/map/init.js
```

A backup was also created:

```text
/usr/lib/python3/dist-packages/htdocs/plugins/map/init.js.bak
```

The timestamps are:

```text
15:14:04  init.js modified
15:14:18  init.js.bak created
```

This is particularly important because the map frontend is responsible for displaying aircraft on the OpenWebRX+ map.

The modification was part of the investigation into aircraft continuing to appear on the map even when changes were made to the backend aircraft data.

---

# 10. Additional OpenWebRX+ Files Touched During the Work

The following files were also modified/touched during the same period:

```text
/usr/lib/python3/dist-packages/htdocs/map-leaflet.js
/usr/lib/python3/dist-packages/htdocs/include/header.include.html
/usr/lib/python3/dist-packages/owrx/controllers/clients.py
```

Their timestamps were:

```text
11:04:33  owrx/controllers/clients.py
11:04:33  htdocs/map-leaflet.js
11:04:33  htdocs/include/header.include.html
```

These files should be considered part of the broader OpenWebRX+ modification/troubleshooting session.

However, unlike the explicitly identified ADS-B files, their exact functional role in the ADS-B modification should be verified from their diffs before describing specific code changes in the final change log.

---

# 11. Configuration and Runtime Investigation

The following OpenWebRX+ configuration was investigated:

```text
/etc/openwebrx/openwebrx.conf
```

The installed ADS-B executable was investigated:

```text
/usr/bin/dump1090-fa
```

The runtime environment of `dump1090-fa` was also investigated, including:

```text
/run/dump1090-fa/
```

The purpose was to determine:

* Which process was producing aircraft data.
* Which TCP port was providing Beast data.
* Where `aircraft.json` was being generated.
* Which JSON file OpenWebRX+ was actually consuming.
* Whether aircraft information was being cached.
* Whether aircraft were being regenerated after removal.
* Whether the map frontend was independently obtaining aircraft data.

---

# 12. Aircraft Map Display Problem

One of the main remaining problems was that:

**Aircraft continued to be displayed on the OpenWebRX+ map even after changes were made to the aircraft JSON data.**

This indicated that the aircraft display was not necessarily controlled exclusively by the JSON file being modified.

The investigation therefore expanded from the data source into the complete processing chain:

```text
ADS-B receiver
       ↓
dump1090-fa
       ↓
Beast/network data
       ↓
aircraft processing
       ↓
OpenWebRX+ backend
       ↓
OpenWebRX+ frontend
       ↓
Map JavaScript
       ↓
Aircraft markers
```

This led to modifications of both backend Python code and frontend JavaScript.

---

# 13. Confirmed File Change Timeline

The confirmed September 6, 2026 timeline is:

| Time     | File                                        | Action           |
| -------- | ------------------------------------------- | ---------------- |
| 13:51:51 | `/usr/local/bin/aircraft-sync.sh`           | Created/modified |
| 13:52:18 | `/etc/systemd/system/aircraft-sync.service` | Created/modified |
| 14:09:28 | `owrx/aircraft/__init__.py.bak-adsb`        | Backup created   |
| 14:09:57 | `owrx/aircraft/__init__.py`                 | Modified         |
| 14:10:27 | `owrx/aircraft/__pycache__/__init__.pyc`    | Regenerated      |
| 14:13:15 | `owrx/__main__.py`                          | Modified         |
| 14:13:30 | `owrx/__pycache__/__main__.pyc`             | Regenerated      |
| 14:22:38 | `csdr/chain/aircraft.py`                    | Modified         |
| 14:22:54 | `csdr/chain/__pycache__/aircraft.pyc`       | Regenerated      |
| 15:14:04 | `htdocs/plugins/map/init.js`                | Modified         |
| 15:14:18 | `htdocs/plugins/map/init.js.bak`            | Backup created   |

---

# 14. Final ADS-B File Inventory

## Confirmed ADS-B source/backend modifications

```text
/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py
/usr/lib/python3/dist-packages/owrx/__main__.py
/usr/lib/python3/dist-packages/csdr/chain/aircraft.py
```

## Confirmed frontend/map modification

```text
/usr/lib/python3/dist-packages/htdocs/plugins/map/init.js
```

## ADS-B synchronization

```text
/usr/local/bin/aircraft-sync.sh
/etc/systemd/system/aircraft-sync.service
```

## Backups

```text
/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py.bak-adsb
/usr/lib/python3/dist-packages/htdocs/plugins/map/init.js.bak
```

## Aircraft data/runtime files

```text
/tmp/dump1090/aircraft.json
/tmp/owrx-adsb/aircraft.json
```

## Additional OpenWebRX+ files touched during the session

```text
/usr/lib/python3/dist-packages/htdocs/map-leaflet.js
/usr/lib/python3/dist-packages/htdocs/include/header.include.html
/usr/lib/python3/dist-packages/owrx/controllers/clients.py
```

---

# 15. Current Status

The ADS-B integration has been substantially investigated and modified at multiple levels.

The system now includes:

1. A confirmed working ADS-B Beast source.
2. `dump1090-fa` as the ADS-B data producer.
3. A dedicated aircraft synchronization script.
4. A systemd service for the synchronization process.
5. Modified OpenWebRX+ aircraft processing.
6. Modified OpenWebRX+ main application code.
7. Modified CSDR aircraft processing.
8. Modified OpenWebRX+ map JavaScript.
9. Aircraft JSON files used for synchronization and testing.
10. Backups of important modified source files.

The remaining technical issue is determining why aircraft markers continue to appear on the OpenWebRX+ map despite changes to the aircraft data.

The most likely area for further investigation is the complete relationship between the backend aircraft processor, the synchronized JSON source, and the frontend map JavaScript.

---

# 16. Recommended Next Step

Before making further changes, the exact modifications should be recorded with `diff`.

For the OpenWebRX+ aircraft module:

```bash
diff -u \
/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py.bak-adsb \
/usr/lib/python3/dist-packages/owrx/aircraft/__init__.py
```

For the map JavaScript:

```bash
diff -u \
/usr/lib/python3/dist-packages/htdocs/plugins/map/init.js.bak \
/usr/lib/python3/dist-packages/htdocs/plugins/map/init.js
```

For the CSDR aircraft module, search for an available backup:

```bash
find /usr/lib/python3/dist-packages/csdr \
-type f \( -name 'aircraft.py*' -o -name '*aircraft*.bak*' \) -ls
```

These comparisons will allow the final report to document not only **which files were modified**, but also **exactly what code was changed in each file**.

---

## Conclusion

The ADS-B project evolved from a simple aircraft JSON synchronization task into a full investigation of the OpenWebRX+ ADS-B processing and map-display pipeline.

The work involved the ADS-B receiver/data source, `dump1090-fa`, JSON synchronization, systemd automation, OpenWebRX+ Python processing, CSDR aircraft processing, and the browser-side map implementation.

The filesystem timestamps confirm that the following core files were modified during the September 6 ADS-B troubleshooting session:

```text
owrx/aircraft/__init__.py
owrx/__main__.py
csdr/chain/aircraft.py
htdocs/plugins/map/init.js
aircraft-sync.sh
aircraft-sync.service
```

This provides a documented baseline for continuing the ADS-B investigation and for restoring or comparing the system if required.
