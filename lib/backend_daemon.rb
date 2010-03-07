module AutomateAT
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
