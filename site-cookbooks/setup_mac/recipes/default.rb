#
# Cookbook Name:: setup_mac
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require 'shellwords'

passwd = node["etc"]["passwd"].dup
users = passwd.reject do |u, data|
  u =~ /^_/ || %w! daemon Guest nobody root !.include?(u)
end

if users.size > 1
  raise "Cannot determine the user (#{users})"
end

username = users.first.first
userdata = users.first.last



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
  "http://cachefly.alfredapp.com/Alfred_2.0.9_214.zip" => "Alfred 2",
}.each_pair do |url, name|
  unless File.exist?("/Applications/#{name}.app")
    download_to = "#{Chef::Config[:file_cache_path]}/#{File.basename(url)}"
    remote_file download_to do
      source url
    end
    execute "unzip #{download_to} -d /Applications/"
    app_path = Shellwords.shellescape("/Applications/#{name}.app")
    execute "chown -R #{username}:staff #{app_path}"
  end
end

%w! autossh zsh git !.each do |p|
  package p do
    provider Chef::Provider::Package::Homebrew
  end
end

user username do
  action :modify
  shell '/bin/zsh'
end

execute "dotfiles/setup.sh" do
  command File.expand_path(".dotfiles/setup.sh", userdata['dir'])
  user username
  action :nothing
end

git File.expand_path(".dotfiles", userdata['dir']) do
  repository "git@github.com:ryotarai/dotfiles.git"
  notifies :run, "execute[dotfiles/setup.sh]"
  user username
end

git File.expand_path(".oh-my-zsh", userdata['dir']) do
  repository "git://github.com/robbyrussell/oh-my-zsh.git"
  user username
end

git File.expand_path(".rbenv", userdata['dir']) do
  repository 'https://github.com/sstephenson/rbenv.git'
  user username
end

directory File.expand_path(".rbenv/plugins", userdata['dir']) do
  user username
end

git File.expand_path(".rbenv/plugins/ruby-build", userdata['dir']) do
  repository 'https://github.com/sstephenson/ruby-build.git'
  user username
end

