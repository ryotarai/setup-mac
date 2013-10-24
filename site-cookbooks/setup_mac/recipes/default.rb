#
# Cookbook Name:: setup_mac
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

user = "ryota"

dmg_package 'Google Chrome' do
  dmg_name 'googlechrome'
  source   'https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg'
  action   :install
end

unless File.exist?('/Applications/iTerm.app')
  download_to = "#{Chef::Config[:file_cache_path]}/iTerm2_v1_0_0.zip"
  remote_file download_to do
    source 'http://iterm2.com/downloads/stable/iTerm2_v1_0_0.zip'
  end
  
  execute "unzip #{download_to} -d /Applications/"
  execute "chown -R #{user}:staff /Applications/iTerm.app"
end

package 'autossh' do
  provider Chef::Provider::Package::Homebrew
end

