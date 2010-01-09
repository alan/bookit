require File.dirname(__FILE__) + '/spec_helper'

describe AutomateAT::Scrapper do
  before(:each) do
    @scrapper = AutomateAT::Scrapper.new(Nokogiri::HTML::Document.new)
  end
  
  describe "#get_bookable_dates" do

    before(:each) do
      @data = Nokogiri::HTML::Document.parse(File.open(File.dirname(__FILE__ )+ "/stubs/full_dom"))
    end

    it "should exclude 'Time' from the results" do
      @scrapper.get_bookable_dates(@data).should_not include('Time')
    end

    it "should include the 8 dates" do
      result = @scrapper.get_bookable_dates(@data)
      result.size.should == 8
      result.should == ["Friday, 4 Dec", "Saturday, 5 Dec", "Sunday, 6 Dec", "Monday, 7 Dec", 
              "Tuesday, 8 Dec", "Wednesday, 9 Dec", "Thursday, 10 Dec", "Friday, 11 Dec"]
    end
  end
  
  describe "#get_available_courts" do
    it "should return a hash with the available times" do
      data = Nokogiri::HTML::Document.parse(File.open(File.dirname(__FILE__ )+ "/stubs/full_dom"))
      processor = AutomateAT::Scrapper.new(data)
      processor.get_available_courts.should == {"Monday, 7 Dec"=> ["8:00am", "11:00am", "12:00pm", "1:00pm", "2:00pm"], 
                                                 "Tuesday, 8 Dec"=>["12:00pm"], 
                                                 "Saturday, 5 Dec"=>["8:00am"], 
                                                 "Friday, 11 Dec"=>["7:00am", "8:00am", "1:00pm", "3:00pm", "8:00pm", "9:00pm"], 
                                                 "Thursday, 10 Dec"=>["7:00am", "8:00am", "9:00am", "10:00am", "3:00pm", "10:00pm"], 
                                                 "Wednesday, 9 Dec"=>["10:00pm"]
                                                 }
    end
  end
end