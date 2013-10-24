#
# Cookbook Name:: setup_mac
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require 'shellwords'

user = nil
user_data = nil
node["etc"]["passwd"].find do |u, data|
  if u !~ /^_/ && !(%w! daemon Guest nobody root !.include?(u))
    user = u
    user_data = data
  end
end

dmg_package 'MacVim-Kaoriya' do
  volumes_dir 'MacVim-Kaoriya'
  app 'MacVim'
  source 'https://macvim-kaoriya.googlecode.com/files/macvim-kaoriya-20131023.dmg'
  action   :install
end

dmg_package 'Google Chrome' do
  dmg_name 'googlechrome'
  source   'https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg'
  action   :install
end

{
  "http://iterm2.com/downloads/stable/iterm2_v1_0_0.zip" => "iTerm",
  "http://i.agilebits.com/dist/1P/mac4/1Password-4.0.2.zip" => "1Password 4",
}.each_pair do |url, name|
  unless File.exist?("/Applications/#{name}.app")
    download_to = "#{Chef::Config[:file_cache_path]}/#{File.basename(url)}"
    remote_file download_to do
      source url
    end
    execute "unzip #{download_to} -d /Applications/"
    app_path = Shellwords.shellescape("/Applications/#{name}.app")
    execute "chown -R #{user}:staff #{app_path}"
  end
end

%w! autossh zsh !.each do |p|
  package p do
    provider Chef::Provider::Package::Homebrew
  end
end

user user do
  action :modify
  shell '/bin/zsh'
end

execute "dotfiles/setup.sh" do
  command File.expand_path(".dotfiles/setup.sh", user_data['dir'])
  user user
  action :nothing
end

git File.expand_path(".dotfiles", user_data['dir']) do
  repository "git@github.com:ryotarai/dotfiles.git"
  notifies :run, "execute[dotfiles/setup.sh]"
  user user
end

git File.expand_path(".oh-my-zsh", user_data['dir']) do
  repository "git://github.com/robbyrussell/oh-my-zsh.git"
  user user
end


