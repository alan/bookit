require 'config/boot'

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
  
  module Daemon
    CHECK_EVERY = 5 * 60
    DAY_IN_SECONDS = 24 * 60 * 60

    def day_setup
      AutomateAT::Bookit.logger.info("Start of day")
      AutomateAT::Bookit.go
      day = EM::PeriodicTimer.new(CHECK_EVERY){
        AutomateAT::Bookit.go
      }

      # Cancel previous event at 23:00
      seconds_let = Time.parse('23:00') - Time.now
      EM::Timer.new(seconds_let){
        day.cancel
        AutomateAT::Bookit.logger.info("End of day")
        setup_night
      }
    end

    def setup_night
      AutomateAT::Bookit.logger.info("Start of night")
      EM::Timer.new(time_left_to_openning){
        AutomateAT::Bookit.logger.info("End of night")
        day_setup
      }
    end

    def time_left_to_openning
      time = Time.now.hour == 23 ? Time.parse('08:00') + DAY_IN_SECONDS : Time.parse('08:00')
      time - Time.now 
    end
    
    def start
      AutomateAT::Bookit.engine.delete_all
      AutomateAT::Bookit.engine.setup_wanted_times
      
      now = Time.now
      if(now >= Time.parse('08:00') && now <= Time.parse('23:00'))
        day_setup
      else
        setup_night
      end
    end
  end
end
