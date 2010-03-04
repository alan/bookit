class ErrorPageError < StandardError; end;

module AutomateAT
  class DataCollector
    class << self
      def get_courts
        get_indoor_data
      end
  
      private
  
      def get_indoor_data
        landing_page = go_to_landing_page
        indoor_page = agent.click landing_page.link_with(:text => web_opts["court_type"])
        indoor_page.parser
      rescue ErrorPageError
        Nokogiri::HTML::Document.new
      end
  
      def go_to_landing_page
        login_page = agent.get(web_opts['landing'])
        if login_page.uri.to_s =~ /Error/
          Bookit.logger.error "Got error page"
          raise ErrorPageError 
        end
        form = login_page.forms.first
        form.send(web_opts['password_field'], web_opts['password'])
        form.send(web_opts['user_field'], web_opts['username'])
        agent.submit(form, form.buttons.first)
      end
  
      def agent
        @agent ||= Mechanize.new {|agent|
          agent.user_agent_alias = 'Mac Safari'
          agent.log = Bookit.logger
          agent.max_history = 1
        }
      end
    
      def web_opts
        Bookit::CONFIG['web']
      end
    end
  end
end