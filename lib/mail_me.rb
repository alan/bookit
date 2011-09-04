module AutomateAT
  class MailMe
    attr_reader :new_slots

    def initialize(slots)
      @new_slots = slots
    end

    def send_availability
      Pony.mail(email_configuration) unless @new_slots.empty?
    end

    def generate_body
      body_file = File.dirname(__FILE__) + "/../templates/email_body.erb"
      template = File.read(body_file)
      body = ERB.new(template).result(binding)
      body
    end

    def email_configuration
      {
       :to => mail_opts['recipient'],
       :subject => "Tennis courts now available!",
       :html_body => generate_body,
       :via => :smtp,
       :via_options => {
          :address => "smtp.gmail.com",
          :port => "587",
          :authentication => :plain,
          :user_name => mail_opts['user'],
          :password => mail_opts['password'],
          :enable_starttls_auto => true
        }
      }
    end

    private

    def mail_opts
      AutomateAT::Bookit::CONFIG['email']
    end
  end
end
