ENV['APP_ENV'] ||= 'development'

ROOT = File.join(File.dirname(__FILE__), '..')

require File.expand_path(File.join(ROOT, 'vendor', 'gems', 'ruby', '1.8','environment'))
Bundler.require_env("backend")

require 'mechanize'
require 'redis'
require 'pony'
require 'erb'
require 'logger'

$:.unshift File.join(ROOT,'lib')

require 'court_engine'
require 'data_collector'
require 'mail_me'
require 'scraper'