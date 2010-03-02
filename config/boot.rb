ENV['APP_ENV'] ||= 'development'

ROOT = File.join(File.dirname(__FILE__), '..')

begin
  # Require the preresolved locked set of gems.
  require File.expand_path(ROOT + '/.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require("backend")

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