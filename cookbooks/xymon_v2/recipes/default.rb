#
# Cookbook:: xymon_v2
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

#variables
xymon_client_hostname = "#{node['xymon']['esxhostname']}.#{node['domain']}"

#Create xymon user
user 'xymon' do
  comment 'Xymon monitoring user'
  shell '/bin/bash'
end

# Create yum repo for xymon-client
yum_repository "xymon-7" do
  description "Xymon client repo"
  baseurl "http://terabithia.org/rpms/xymon/el7/x86_64/"
  gpgkey 'http://terabithia.org/rpms/RPM-GPG-KEY-JCLEAVER'
  action :create
end

# check for epel repo and install if needed
bash 'remove epel-release' do
  user 'root'
  code <<-EOH
  sudo rpm -e epel-release
  EOH
  not_if { ::File.exist?('/etc/yum.repos.d/epel.repo') }
end

# Install necessary packages
package ['epel-release', 'openssl-devel']
package ['lz4', 'lz4-devel', 'bc', 'sblim-wbemcli', 'pywbem', 'e2fsprogs-devel', 'uuid', 'libuuid', 'libuuid-devel', 'glibc.i686', 'perl-version', 'perl-Data-Dumper', 'perl-XML-LibXML', 'perl-Env', 'perl-devel', 'perl-CPAN', 'java-1.8.0-openjdk-devel', 'python-setuptools']

# Install necessary perl modules
perl_packages_1 = ['perl-JSON-PP', 'perl-Devel-StackTrace', 'perl-Class-Data-Inheritable', 'perl-Convert-ASN1', 'perl-Crypt-OpenSSL-RSA', 'perl-Exception-Class', 'perl-Archive-Zip', 'perl-Path-Class', 'perl-Try-Tiny', 'perl-XML-SAX', 'perl-libxml-perl']
perl_packages_2 = ['perl-version', 'perl-Class-MethodMaker', 'perl-Data-UUID', 'perl-Data-Dump', 'perl-SOAP-Lite', 'perl-LWP-Protocol-https', 'perl-Crypt-OpenSSL-X509', 'perl-Socket6', 'perl-IO-Socket-INET6', 'perl-Net-INET6Glue', 'perl-Crypt-SSLeay', 'perl-XML-NamespaceSupport']

perl_packages_1.each do |perl_package|
  package "install #{perl_package}" do
    package_name "#{perl_package}"
    action :install
  end
end

perl_packages_2.each do |perl_package|
  package "install #{perl_package}" do
    package_name "#{perl_package}"
    action :install
  end
end

# Install xymon client
package 'xymon-client'

link '/usr/lib/libcurl.so.3' do
  to '/usr/lib/libcurl.so.4'
end

# Download and extract vCLI
tar_extract 'https://ip.dancrai.com.au/VMware-vSphere-CLI-6.5.0-4566394.x86_64.tar.gz' do
  target_dir '/tmp'
  creates '/tmp/vmware-vsphere-cli-distrib'
end

# Download and extract PowerChute
tar_extract 'https://ip.dancrai.com.au/pcns420Linux-x86-64.tar.gz' do
  target_dir '/tmp'
  creates '/tmp/Linux_x64'
end

# Copy PowerChute install script
template '/tmp/Linux_x64/install.sh' do
  source 'install.sh.erb'
  owner 'root'
  group 'root'
  mode 00744
end

# Install vCLI
execute 'install vCLI' do
  cwd '/tmp/vmware-vsphere-cli-distrib'
  command 'yes | PAGER=cat ./vmware-install.pl --default'
  action :run
  notifies :restart, 'service[xymon-client]', :immediately
end

# Install PowerChute
execute 'install PCNS' do
  cwd '/tmp/Linux_x64'
  command 'sh install.sh'
end


# Put in place xymon client check files
template '/etc/sysconfig/xymon-client' do
  source 'xymon-client.erb'
  owner 'xymon'
  group 'root'
  mode '0644'
  variables(client_hostname: xymon_client_hostname)
  notifies :restart, 'service[xymon-client]', :immediately
end

template '/etc/xymon.esx' do
  source 'xymon.esx.erb'
  owner 'xymon'
  group 'root'
  mode 00744
  notifies :restart, 'service[xymon-client]', :immediately
end

template '/usr/share/xymon-client/bin/xymonclient-linux.sh' do
  source 'xymonclient-linux.sh.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymon-client]', :immediately
end

template "#{node['xymon']['dir']}/ext/xymon-con.pl" do
  source 'xymon-con.pl.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymon-client]', :immediately
end

template "#{node['xymon']['dir']}/ext/xymon-vmtemp.sh" do
  source 'xymon-vmtemp.sh.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymon-client]', :immediately
end

template "#{node['xymon']['dir']}/ext/xymon-vmhealth.sh" do
  source 'xymon-vmhealth.sh.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymon-client]', :immediately
end

template "#{node['xymon']['dir']}/ext/xymon-vmhealth.py" do
  source 'xymon-vmhealth.py.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymon-client]', :immediately
end

template "#{node['xymon']['dir']}/ext/xymon-vmsnap.sh" do
  source 'xymon-vmsnap.sh.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymon-client]', :immediately
end

template "#{node['xymon']['dir']}/clientlaunch.cfg" do
  source 'clientlaunch.cfg.erb'
  owner 'xymon'
  group 'root'
  mode 00744
  notifies :restart, 'service[xymon-client]', :immediately
end

# Start xymon service
service 'xymon-client' do
  action [ :enable, :start ]
end