ENV['APP_ENV'] ||= 'development'

ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

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

require 'erb'
require 'logger'

$:.unshift File.join(ROOT,'lib')

require 'court_engine'
require 'data_collector'
require 'mail_me'
require 'scraper'

module AutomateAT
  class Bookit
    CONFIG = YAML.load_file(ROOT + '/config/config.yml')[ENV["APP_ENV"]]
    
    def self.engine
      @@engine ||= CourtEngine.new
    end
  
    def self.logger
      @@logger ||= initialize_logger
    end
  
    def self.go
      begin
        raw_data = DataCollector.get_courts
        scrapper = Scraper.new(raw_data)
        new_courts = scrapper.get_available_courts
        engine.save_courts(new_courts)
        mailer = MailMe.new(engine.courts_to_notify)
        mailer.send_availability
        engine.user_notified
      rescue Timeout::Error
        logger.warning = "#{Time.now} :: The scraper timed out"
      end
    end
    
    private
    
    def self.initialize_logger
      case ENV["APP_ENV"]
                  when "development"
                    logger = Logger.new(STDOUT)
                    logger.level = Logger::INFO
                    logger.info "Logger started for development"
                    logger
                  when "test"
                    logger = Logger.new(File.expand_path(ROOT + "/log/test.log"))
                    logger.level = Logger::INFO
                    logger.info "Logger started for test"
                    logger
                  when "production"
                    logger = Logger.new(File.expand_path(ROOT + "/log/production.log"))
                    logger.level = Logger::WARN
                    logger.warn "Logger started for production"
                    logger
                  else
                    puts "Don't know what enviornment you are talking about, using STDOUT"
                    Logger.new(STDOUT)
                  end
    end 
  end
end