module AutomateAT
  class CourtEngine
    
    attr_reader :time_expiration, :adapter
    
    def initialize(time_expiration = 30 * 60)
      @adapter = Redis.new(:host => '127.0.0.1', 
                           :port => 6379, 
                           :thread_safe => true, 
                           :db => CONFIG["db"], 
                           :logger => AutomateAT::logger)
      @time_expiration = time_expiration
    end
    
    def delete_all
      adapter.flushdb
    end
    
    # Change when multi add is implemented in Redis
    def add_time(day, time)
      adapter.sadd(key("available", day), time)
    end
    
    def save_courts(courts)
      adapter.keys("available:*").each{|k| adapter.delete(k)}
      courts.each do |day, times|
        day_key = key("available", day)
        times.each{|time| add_time(day, time)}
      end
    end
    
    def courts_to_notify
      available_dates = adapter.keys("available:*")
      available_dates.inject({}) do |result, availability|
        
        wanted_key = matching_wanted_key_for(availability)
        date = human_date_from_availability_key(availability)
        
        adapter.sinterstore("temp", availability, wanted_key)
        
        notified = adapter.keys(key("notified", date, '*'))
        
        # Can't use SDIFFSTORE as write operations in Redis ignore
        # volatile keys
        times_to_notify = adapter.sdiff("temp", notified)
        
        to_notify_key = key("to_notify", date)
        times_to_notify.each{|time| adapter.sadd(to_notify_key, time)}
        
        data = adapter.smembers(to_notify_key)
        
        result[date] = data if data.any?
        result
      end
    end
    
    def user_notified
      to_notify = adapter.keys("to_notify:*")
      to_notify.each do |key_name|
        date = key_name.gsub("to_notify:", "")
        count = adapter.incr(date).to_s
        adapter.rename(key_name, key("notified", date, count))
        adapter.expire(key("notified", date, count), time_expiration)
      end
    end
    
    def key(*parts)
      parts.inject([]) {|result, part| result << part.gsub(' ', '-')}.join(':')
    end
    
    def setup_wanted_times
      return if adapter.keys("wanted:*").any?
      AutomateAT::CONFIG["wanted_times"].keys.each do |day|
        times = AutomateAT::CONFIG["wanted_times"][day]
        times.split(', ').each{|time| adapter.sadd(key("wanted", day), time)}
      end
    end
    
    private
    
    def human_date_from_availability_key(key)
      key.gsub("available:", "").gsub("-", " ")
    end
    
    def matching_wanted_key_for(date_key)
      day = %w(monday tuesday wednesday thursday friday saturday sunday).find{|d| date_key.downcase.include? d}
      key("wanted", day)
    end
  end
end