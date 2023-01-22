# xymon_v2

Description
===========

A cookbook that installs and configures the xymon monitoring client based on Dancrai specific requirements.

Requirements
============

Platform:
* Centos 7

Attributes
==========

Many different attributes can be changed so that a very custom xymon client experience can be had.
For example you can change the check interval for all the VM checks (vmsnap, vmhealth, vmcon, vmtemp)

`node['xymon']['vmcon_interval'] = '15m'`

The above example will set the check interval for vmcon to 15 minutes.

Available Attributes
--------------------

* `node['xymon']['servers']` - An array of servers to send xymon data to

* `node['xymon']['yellow_temp']` - Temperature threshold to set xymon to yellow (default `25`)

* `node['xymon']['red_temp']` - Temperature threshold to set xymon to red (default `30`)

* `node['xymon']['vmsnap_yellow_time']` - Age in hours a snapshot is kept before xymon turns yellow (default `1`)

* `node['xymon']['vmsnap_red_time']` - Age in hours a snapshot is kept before xymon turns red (default `4`)

* `node['xymon']['client_interval']` - Time interval to collect clientlog (default `5m`)

* `node['xymon']['vmcon_interval']` - Time interval to collect disk consolidation (default `5m`)

* `node['xymon']['vmsnap_interval']` - Time interval to collect snapshots (default `5m`)

* `node['xymon']['vmtemp_interval']` - Time interval to collect temperature (default `5m`)

* `node['xymon']['vmhealth_interval']` - Time interval to collect health information (default `5m`)

The next 5 items can be configured, but please use ***CARE*** when changing anything here as it has big consequences if misconfigured.

* `node['xymon']['dir']` - Local xymon client directory

* `node['xymon']['esxip']` - IP address of ESXi host

* `node['xymon']['xymon_esx']['esxuser']` - User used for monitoring ESXi host

* `node['xymon']['xymonpass']` - Password for above user

* `node['xymon']['esxhostname']` - Hostname of ESXi host server

Using Attributes
----------------

To use the above attributes for a custom xymon monitoring experience you need to put them into a json format as per the below examples.

```json
{
  "xymon": {
    "servers": [
      "xymon.dancrai.com.au",
      "xymon.schenck.com.au"
    ],
    "yellow_temp": "23",
    "vmsnap_interval": "10m"
  }
}
```

This will set:

* The xymon servers to send data to as: `xymon.dancrai.com.au` and `xymon.schenck.com.au`
* The yellow temp threshold to `23`
* The vmsnap check interval to `10` minutes