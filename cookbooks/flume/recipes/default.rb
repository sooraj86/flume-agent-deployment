# coding: UTF-8
# Cookbook Name:: cerner_kafka
# Recipe:: default
#colo = node['domain'].split(".")[-3]
colo='grab'
flumeInstallDir="#{node["flume_collector"]["base_dir"]}/flume_#{node["flume_collector"]["version"]}"
flumeTmp="/tmp/flume_#{node["flume_collector"]["version"]}.tar.gz"
flumeTmpDir="/tmp/flume"
flumeHome="#{node["flume_collector"]["base_dir"]}/flume"
flumeConf="#{flumeInstallDir}/conf"
lockFile="#{flumeInstallDir}/LOCK"

group 'flume' do
  action :create
end

user 'flume' do
  gid 'flume'
  shell "/bin/bash"
  home "/home/flume"
  supports :manage_home => true
end

directory "#{flumeInstallDir}" do
  action :create
  owner 'flume'
  mode 00755
end

directory node["flume_collector"]["pid_dir"] do
  action :create
  owner 'flume'
  mode 00755
end

directory "#{flumeTmpDir}" do
  action :create
  owner 'flume'
  mode 00755
end

%w[/data/d1/flume /data/d1/flume/spool /var/log/flume].each do |path|
  directory path do
    owner 'flume'
    mode '0755'
    action :create
  end
end

remote_file "#{flumeTmp}" do
  action :create_if_missing
  source node["flume_collector"]["download_url"]
  backup false
end

execute "untar flume binary" do
  cwd flumeTmpDir
  command "tar -xvf #{flumeTmp}; mv apache-flume-#{node["flume_collector"]["version"]}-bin/* #{flumeInstallDir}/"
  not_if do
    File.exists? "#{lockFile}"
  end
end

execute "Create Lock file" do
  command "touch #{lockFile}"
  not_if do
    File.exists? "#{lockFile}"
  end
end


template "#{flumeConf}/flume-agent.properties" do
  source "flume-agent.properties.erb"
  owner "flume"
  mode  00644
  variables(
    :kafkabrokers =>node["flume_collector"]["kafka_brokers"][colo],
  )
end

cookbook_file "#{flumeConf}/flume-env.sh" do
  source "flume-env.sh"
  mode "0644"
end

execute "chown flume directory" do
  command "chown -R flume #{flumeInstallDir}"
end

execute "bin execute permissions" do
  command "chmod +x #{flumeInstallDir}/bin/*"
end

link "#{flumeHome}" do
  owner 'flume'
  to "#{flumeInstallDir}"
  link_type :symbolic
end


template "/var/lib/jmxtrans/flume.json" do
  source "flume.json.erb"
  owner "jmxtrans"
  group "jmxtrans"
  mode "0644"
  variables(
    :host => node['hostname'],
    :fqdn => node['fqdn'],
    :graphite_host => node["flume_collector"]["graphitehost"],
    :colo => colo
  )
end


cookbook_file "/etc/supervisor/conf.d/flume.conf" do
  source "flume-supervisor.conf"
  mode "0644"
end
