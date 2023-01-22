name 'xymon_v2'
maintainer 'The Authors'
maintainer_email 'michaels@dancrai.com.au'
license 'All Rights Reserved'
description 'Installs/Configures xymon_v2'
long_description 'Installs/Configures xymon_v2'
version '0.27.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/xymon_v2/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/xymon_v2'

depends 'tar', '~> 2.1.0'