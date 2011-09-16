require 'bundler/setup'
Bundler.require

require File.dirname(__FILE__ + '/lib/yamook')

run Yamook::App
