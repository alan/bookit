ROOT = File.dirname(__FILE__)

require File.expand_path(File.join(ROOT, 'vendor', 'gems', 'environment'))
Bundler.require_env("backend")

require 'mechanize'
require 'redis'
require 'pony'
require 'erb'
require 'logger'

require File.expand_path(File.join(ROOT, 'lib', 'court_engine'))
require File.expand_path(File.join(ROOT, 'lib', 'data_collector'))
require File.expand_path(File.join(ROOT, 'lib', 'mail_me'))
require File.expand_path(File.join(ROOT, 'lib', 'scraper'))