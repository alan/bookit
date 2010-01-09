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
      end
  
      def go_to_landing_page
        login_page = agent.get(web_opts['landing'])
        form = login_page.forms.first
        form.send(web_opts['password_field'], web_opts['password'])
        form.send(web_opts['user_field'], web_opts['username'])
        agent.submit(form, form.buttons.first)
      end
  
      def agent
        @agent ||= WWW::Mechanize.new {|agent|
          agent.user_agent_alias = 'Mac Safari'
          agent.log = AutomateAT::logger
        }
      end
    
      def web_opts
        AutomateAT::CONFIG['web']
      end
    end
  end
end