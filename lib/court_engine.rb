module AutomateAT
  class CourtEngine

    attr_reader :time_expiration, :adapter

    def initialize(time_expiration = 30 * 60)
      @adapter = Redis.new(:host => '127.0.0.1',
                           :port => 6379,
                           :thread_safe => true,
                           :db => Bookit::CONFIG["db"],
                           :logger => Bookit::logger)
      @time_expiration = time_expiration
    end

    def delete_all
      adapter.flushdb
    end

    def save_courts(courts)
      old_available = adapter.smembers("available")
      adapter.pipelined do
        old_available.each{|o| adapter.del(o)}
        adapter.del("available")

        courts.each do |day, times|
          day_key = key("available", day)
          adapter.sadd("available", day_key)
          times.each{|time| adapter.sadd(day_key, time)}
        end
      end
    end

    def courts_to_notify
      available_dates = adapter.smembers("available")
      available_dates.inject({}) do |result, availability|

        # keys to be used
        wanted_key = matching_wanted_key_for(availability)
        date = human_date_from_availability_key(availability)
        to_notify_key = key("to_notify", date)
        notified_keys = adapter.smembers(key("notified", date))

        # found => has the times that is available that I am interested

        adapter.sinterstore("found", availability, wanted_key)

        data = adapter.sdiff("found", *notified_keys)

        data.each{|slot| adapter.sadd(to_notify_key, slot)}
        data = adapter.smembers(to_notify_key)

        if data.any?
          adapter.sadd("to_notify", to_notify_key)
          result[date] = data
        end
        result
      end
    end

    def user_notified
      to_notify = adapter.smembers("to_notify")
      to_notify.each do |key_name|
        date = key_name.gsub("to_notify:", "")
        AutomateAT::Bookit.logger.warn("Date counter: #{date}")
        count = adapter.incr(date).to_s
        notified_key = key("notified", date, count)
        adapter.rename(key_name, notified_key)
        adapter.sadd(key("notified", date), notified_key)
        adapter.expire(notified_key, time_expiration)
      end
    end

    def key(*parts)
      parts.inject([]) {|result, part| result << part.gsub(' ', '-')}.join(':')
    end

    def setup_wanted_times
      Bookit::CONFIG["wanted_times"].each do |day, times|
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
