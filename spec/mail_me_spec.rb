require File.dirname(__FILE__) + '/spec_helper'

describe AutomateAT::MailMe do
  context "Creating a mailer" do
    it "should raise an error if no data is given" do
      lambda{ AutomateAT::MailMe.new }.should raise_error
    end
    
    it "should should not blow up when data is given" do
      lambda { AutomateAT::MailMe.new({}) }.should_not raise_error
    end
  end
  
  context "Sending email" do
    
    before(:each) do
      Pony.stub!(:mail)
    end
    
    it "should not send email if no available courts" do
      Pony.should_not_receive(:mail)
      AutomateAT::MailMe.new({})
    end
    
    describe "email body" do
      it "should generate a body with the available courts" do
        mailer = AutomateAT::MailMe.new({"Wednesday, 20 Nov" => ["9:00am"]})
        body = mailer.generate_body
        body.should match(/Wednesday,\s20 Nov/)
        body.should match(/9:00am/)
      end
    end
    
    describe "email configuration" do
      it "should use the settings from the config file" do
        mailer = AutomateAT::MailMe.new({"Wednesday, 20 Nov" => ["9:00am"]})
        conf = mailer.email_configuration
        conf[:to].should == "destination.email"
        conf[:smtp][:user].should == "john.smith"
        conf[:smtp][:password].should == "the_password"
      end
    end
    
    it "should use the email configuration to send emails" do
      mailer = AutomateAT::MailMe.new({"Wednesday, 20 Nov" => ["9:00am"]})
      Pony.should_receive(:mail).with(mailer.email_configuration)
      mailer.send_availability
    end

  end
end