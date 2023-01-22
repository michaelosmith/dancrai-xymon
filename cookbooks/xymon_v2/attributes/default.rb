# Setup some defaults for recipes.

# Most of these settings are available to be overritten by using node attributes #
##################################################################################

# Setting for xymon servers to send data to
default['xymon']['servers'] = []

# settings for /etc/xymon.esx file
default['xymon']['esxuser']            = 'xymon'
default['xymon']['yellow_temp']        = '25'
default['xymon']['red_temp']           = '30'
default['xymon']['vmsnap_yellow_time'] = '1'
default['xymon']['vmsnap_red_time']    = '4'

# Settings for /etc/xymon-client/clientlaunch.cfg
default['xymon']['client_interval']    = '5m'
default['xymon']['vmcon_interval']     = '5m'
default['xymon']['vmsnap_interval']    = '5m'
default['xymon']['vmtemp_interval']    = '5m'
default['xymon']['vmhealth_interval']  = '5m'

# These settings are unlikely to be changed but can still be overritten by using node attributes #
# BE CAREFUL #
##################################################################################################

# Xymon client directory
default['xymon']['dir'] = '/etc/xymon-client'

# settings for /etc/xymon.esx file
default['xymon']['esxip']     = ::File.read('/etc/esxip').chomp
default['xymon']['xymonpass'] = ::File.read('/etc/xymonpass').chomp

# Frist part of hostname to be sent to xymon server
default['xymon']['esxhostname'] = ::File.read('/etc/esxhostname').chomp.downcase

# List of CIM elements to ignore ( for vmhealth stat)
default['xymon']['vmhealth']['ignore_list'] = [ "Remote Management Device 0 NetStat: Connected", "System Board 1 Riser 3 Presence 0: Connected", "Disk Drive Bay 2 Cable SAS B1 0: Connected", "Disk Drive Bay 2 Cable SAS A1 0: Connected", "Disk Drive Bay 2 Cable PCIe B2 0: Connected", "Disk Drive Bay 2 Cable PCIe A2 0: Connected", "Disk Drive Bay 2 Cable PCIe B1 0: Connected", "Disk Drive Bay 2 Cable PCIe A1 0: Connected", "Disk Drive Bay 2 Cable PCIe B0 0: Connected", "Disk Drive Bay 2 Cable PCIe A0 0: Connected" ]