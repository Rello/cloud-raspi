#!/usr/bin/python3
# python3 all_sensors.py

    NCUser = 'xxx'
    NCPass = 'xxx'

from datetime import datetime
import requests
from miflora.miflora_poller import MiFloraPoller, \
    MI_CONDUCTIVITY, MI_MOISTURE, MI_LIGHT, MI_TEMPERATURE, MI_BATTERY
from btlewrap.gatttool import GatttoolBackend
from urllib.request import urlopen

Sensors = {
        "1-Jadebaum": {
                "mac": "C4:7C:8D:63:83:D9"
        },
        "2-Ficus": {
                "mac": "C4:7C:8D:63:83:DB"
        },
        "3-WRose": {
                "mac": "C4:7C:8D:63:83:AD"
        },
        "4-Chilli": {
                "mac": "C4:7C:8D:63:83:C5"
        },
        "5-Birke": {
                "mac": "C4:7C:8D:63:83:49"
        }
};

for sensor, options in Sensors.items():
    print ("--------" + sensor + "--------")
    poller = MiFloraPoller(options["mac"], GatttoolBackend)
    try:
        value=(poller.parameter_value(MI_MOISTURE))
        battery=(poller.parameter_value(MI_BATTERY))
    except Exception:
        continue
    #name=(poller.name())
    #firmware=(poller.firmware_version())
    #temperature=(poller.parameter_value("temperature"))
    #light=(poller.parameter_value(MI_LIGHT))
    #conductivity=(poller.parameter_value(MI_CONDUCTIVITY))

    print ("--------" + sensor + "--------")
    #print (moisture,light,temperature,battery)
    print (value, battery)
    print ("\n")

    headers = {'Content-Type': 'application/json'}
    now = datetime.now().strftime('%Y-%m-%d %H:%M:00')

    url = 'https://home.scherello.de/owncloud/apps/analytics/api/1.0/adddata/' + '18'
    payload = {'dimension1': sensor, 'dimension2': now, 'dimension3': value}
    r = requests.post(url, json=payload, headers=headers, auth=(NCUser, NCPass))

    url = 'https://home.scherello.de/owncloud/apps/analytics/api/1.0/adddata/' + '20'
    payload = {'dimension1': sensor, 'dimension2': now, 'dimension3': battery}
    r = requests.post(url, json=payload, headers=headers, auth=(NCUser, NCPass))
