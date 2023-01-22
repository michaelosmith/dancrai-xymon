#
# Cookbook:: xymon
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

ohai_plugin 'ovfconf'

releasever      = node['packages']['centos-release']['version']
hostname        = node['hostname']
xymon_home      = '/etc/xymon-client'
# cpan_modules    = %w{ JSON::PP Devel::StackTrace Class::Data::Inheritable Convert::ASN1 Crypt::OpenSSL::RSA Crypt::X509 UUID::Random Archive::Zip Path::Class Try::Tiny Crypt::SSLeay version Class::MethodMaker UUID Data::Dump SOAP::Lite LWP::Protocol::https Socket6 IO::Socket::INET6 Net::INET6Glue }

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

package ['epel-release', 'openssl-devel']
package ['lz4', 'lz4-devel', 'bc', 'sblim-wbemcli', 'pywbem', 'e2fsprogs-devel', 'uuid', 'libuuid', 'libuuid-devel', 'glibc.i686', 'perl-version', 'perl-Data-Dumper', 'perl-XML-LibXML', 'perl-Env', 'perl-devel', 'perl-CPAN', 'java-1.8.0-openjdk-devel']
# installing perl modules
perl_packages_1 = ['perl-JSON-PP', 'perl-Devel-StackTrace', 'perl-Class-Data-Inheritable', 'perl-Convert-ASN1', 'perl-Crypt-OpenSSL-RSA', 'perl-Exception-Class', 'perl-Archive-Zip', 'perl-Path-Class', 'perl-Try-Tiny', 'perl-XML-SAX', 'perl-libxml-perl']
perl_packages_2 = ['perl-version', 'perl-Class-MethodMaker', 'perl-Data-UUID', 'perl-Data-Dump', 'perl-SOAP-Lite', 'perl-LWP-Protocol-https', 'perl-Crypt-OpenSSL-X509', 'perl-Socket6', 'perl-IO-Socket-INET6', 'perl-Net-INET6Glue', 'perl-Crypt-SSLeay', 'perl-XML-NamespaceSupport']
package 'xymon-client'

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

link '/usr/lib/libcurl.so.3' do
  to '/usr/lib/libcurl.so.4'
end

# Install CPAN modules for vMWare CLI
# cpan_modules.each do |cpan_module|
#   cpan_client cpan_module do
#     user 'root'
#     group 'root'
#     force true
#     install_type 'cpan_module'
#     action 'install'
#   end
# end

# remote_file '/tmp/VMware-vSphere-CLI-6.5.0-4566394.x86_64.tar.gz' do
#   source 'https://www.dropbox.com/s/h4rpb34wr8qwuqg/VMware-vSphere-CLI-6.5.0-4566394.x86_64.tar.gz?dl=1'
#   mode '0755'
# end

tar_extract 'https://ip.dancrai.com.au/VMware-vSphere-CLI-6.5.0-4566394.x86_64.tar.gz' do
  target_dir '/tmp'
  creates 'VMware-vSphere-CLI-6.5.0-4566394.x86_64.tar.gz'
end

tar_extract 'https://ip.dancrai.com.au/pcns420Linux-x86-64.tar.gz' do
  target_dir '/tmp'
  creates 'pcns420Linux-x86-64.tar.gz'
end

template '/tmp/Linux_x64/install.sh' do
  source 'install.sh.erb'
  owner 'root'
  group 'root'
  mode 00744
end

execute 'install vCLI' do
  cwd '/tmp/vmware-vsphere-cli-distrib'
  command 'yes | PAGER=cat ./vmware-install.pl --default'
  action :run
end

execute 'install PCNS' do
  cwd '/tmp/Linux_x64'
  command 'sh install.sh'
end

# Start xymon service
service 'xymonlaunch' do
  action [ :enable, :start ]
end

template '/etc/sysconfig/xymon-client' do
  source 'xymon-client.erb'
  owner 'xymon'
  group 'root'
  mode 00744
  variables(vmware_host_name: node['ovfconf']['vmware_host_name'])
  notifies :restart, 'service[xymonlaunch]', :immediately
end

template '/etc/xymon.esx' do
  source 'xymon.esx.erb'
  owner 'xymon'
  group 'root'
  mode 00744
  variables(esx_host_ip: node['ovfconf']['esx_host_ip'],
            esx_xymon_password: node['ovfconf']['esx_xymon_password'])
  notifies :restart, 'service[xymonlaunch]', :immediately
end

template '/usr/share/xymon-client/bin/xymonclient-linux.sh' do
  source 'xymonclient-linux.sh.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymonlaunch]', :immediately
end

template "#{xymon_home}/ext/xymon-con.pl" do
  source 'xymon-con.pl.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymonlaunch]', :immediately
end

template "#{xymon_home}/ext/xymon-vmtemp.sh" do
  source 'xymon-vmtemp.sh.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymonlaunch]', :immediately
end

template "#{xymon_home}/ext/xymon-vmhealth.sh" do
  source 'xymon-vmhealth.sh.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymonlaunch]', :immediately
end

template "#{xymon_home}/ext/xymon-vmhealth.py" do
  source 'xymon-vmhealth.py.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymonlaunch]', :immediately
end

template "#{xymon_home}/ext/xymon-vmsnap.sh" do
  source 'xymon-vmsnap.sh.erb'
  owner 'xymon'
  group 'root'
  mode 00755
  notifies :restart, 'service[xymonlaunch]', :immediately
end

template "#{xymon_home}/clientlaunch.cfg" do
  source 'clientlaunch.cfg.erb'
  owner 'xymon'
  group 'root'
  mode 00744
  notifies :restart, 'service[xymonlaunch]', :immediately
end
