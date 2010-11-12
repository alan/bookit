require 'spec_helper'

describe AutomateAT::Scraper do
  before(:each) do
    @scraper = AutomateAT::Scraper.new(Nokogiri::HTML::Document.new)
  end
  
  describe "#get_bookable_dates" do

    before(:each) do
      @data = Nokogiri::HTML::Document.parse(File.open(File.dirname(__FILE__ )+ "/stubs/full_dom"))
    end

    it "should exclude 'Time' from the results" do
      @scraper.get_bookable_dates(@data).should_not include('Time')
    end

    it "should include the 8 dates" do
      result = @scraper.get_bookable_dates(@data)
      result.size.should == 8
      result.should == ["Friday, 4 Dec", "Saturday, 5 Dec", "Sunday, 6 Dec", "Monday, 7 Dec", 
              "Tuesday, 8 Dec", "Wednesday, 9 Dec", "Thursday, 10 Dec", "Friday, 11 Dec"]
    end
  end
  
  describe "#get_available_courts" do
    it "should return a hash with the available times" do
      data = Nokogiri::HTML::Document.parse(File.open(File.dirname(__FILE__ )+ "/stubs/full_dom"))
      processor = AutomateAT::Scraper.new(data)
      
      courts = processor.get_available_courts
      courts["Monday, 7 Dec"].should include("8:00am", "11:00am", "12:00pm", "1:00pm", "2:00pm")
      courts["Monday, 7 Dec"].should have(5).items
      courts["Tuesday, 8 Dec"].should include("12:00pm")
      courts["Tuesday, 8 Dec"].should have(1).item
      courts["Wednesday, 9 Dec"].should include("10:00pm")
      courts["Wednesday, 9 Dec"].should have(1).item
      courts["Thursday, 10 Dec"].should include("7:00am", "8:00am", "9:00am", "10:00am", "3:00pm", "10:00pm")
      courts["Thursday, 10 Dec"].should have(6).items
      courts["Friday, 11 Dec"].should include("7:00am", "8:00am", "1:00pm", "3:00pm", "8:00pm", "9:00pm")
      courts["Friday, 11 Dec"].should have(6).items
      courts["Saturday, 5 Dec"].should include("8:00am")
      courts["Saturday, 5 Dec"].should have(1).item
    end
  end
end