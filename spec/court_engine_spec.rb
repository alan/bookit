require 'spec_helper'

describe AutomateAT::CourtEngine do
  before(:all) do
    @engine = AutomateAT::CourtEngine.new
  end

  context "#time_expiration" do
    it "should have a default expiration time of 30 minutes" do
      @engine.time_expiration.should == 30 * 60
    end

    it "should be able to set the time expiration on creation" do
      redis_db = AutomateAT::CourtEngine.new(1)
      redis_db.time_expiration.should == 1
    end
  end

  it "should expose the ruby redis adapter" do
    @engine.adapter.should be_instance_of(Redis)
  end

  it "should be able to delete all keys" do
    @engine.adapter["foo"] = "bar"
    @engine.delete_all
    @engine.adapter.keys('*').size.should == 0
  end

  context "#key" do
    it "should be able to generate a key from arguments with spaces" do
      @engine.key("Wednesday, 25 Nov", "9:00pm").should == "Wednesday,-25-Nov:9:00pm"
    end

    it "should generate standard key from any number of arguments" do
      @engine.key("boo", "foo", "bar").should == "boo:foo:bar"
    end
  end

  context "#setup_wanted_times" do
    it "should save the wanted times from the config yaml" do
      @engine.setup_wanted_times
      @engine.adapter.smembers("wanted:monday").should include("6:00pm", "7:00pm", "8:00pm", "9:00pm")
    end
    # TODO review, only load once from yaml (with no arguments)
    it "should override wanted times" do
      @engine.adapter.sadd("wanted:monday", "7:00pm")
      @engine.setup_wanted_times
      @engine.adapter.smembers("wanted:monday").should include("6:00pm", "7:00pm", "8:00pm", "9:00pm")
    end
  end

  context "notification of courts to user" do
    before(:each) do
      @engine.setup_wanted_times
    end

    describe "#courts_to_notify" do
      before(:each) do
        @engine.save_courts({"Thursday, 21 Nov" => ["7:00am", "7:00pm", "8:00pm"], "Friday, 22 Nov" => ["9:00pm"]})
      end

      it "should only include times which the user wants to know about" do
        @engine.courts_to_notify.should == {"Friday, 22 Nov" => ["9:00pm"], "Thursday, 21 Nov" => ["8:00pm", "7:00pm"]}
      end

      it "should not include times which have been notified recently" do
        @engine.adapter.sadd("notified:Thursday,-21-Nov:1", "8:00pm")
        @engine.adapter.sadd("notified:Friday,-22-Nov:1", "9:00pm")
        @engine.adapter.sadd("notified:Thursday,-21-Nov", "notified:Thursday,-21-Nov:1")
        @engine.adapter.sadd("notified:Friday,-22-Nov", "notified:Friday,-22-Nov:1")
        @engine.courts_to_notify.should == {"Thursday, 21 Nov" => ["7:00pm"]} 
      end
    end

    describe "#user_notified" do
      before(:each) do
        @engine.save_courts({"Thursday, 21 Nov" => ["8:00pm"]})
        @engine.courts_to_notify
      end

      it "should mark each time as notified" do
        @engine.user_notified
        @engine.adapter.smembers("notified:Thursday,-21-Nov:1").should == ["8:00pm"]
      end

      it "should set the ttl for the notified keys" do
        @engine.adapter.should_receive(:expire).with("notified:Thursday,-21-Nov:1", @engine.time_expiration)
        @engine.user_notified
      end

      it "should delete the to_notify keys" do
        @engine.user_notified
        @engine.adapter.exists("to_notify:Thursday,-21-Nov").should be_false
      end
    end
  end

  context "saving the latest courts found" do
    describe "#save_courts" do
      it "should save all the courts available in sets for each date" do
        @engine.save_courts({"Thursday, 21 Nov" => ["8:00pm"], "Friday, 22 Nov" => ["9:00pm"]})
        @engine.adapter.smembers("available").should include("available:Thursday,-21-Nov", "available:Friday,-22-Nov")
        @engine.adapter.smembers("available:Thursday,-21-Nov").should == ["8:00pm"]
        @engine.adapter.smembers("available:Friday,-22-Nov").should == ["9:00pm"]
      end

      it "should delete previous availability" do
        @engine.save_courts({"Thursday, 21 Nov" => ["8:00pm"]})
        @engine.save_courts({"Thursday, 21 Nov" => ["9:00pm"]})
        @engine.adapter.smembers("available").should == ["available:Thursday,-21-Nov"]
        @engine.adapter.smembers("available:Thursday,-21-Nov").should == ["9:00pm"]
      end
    end
  end

  describe "end to end" do
    it "should only notify new courts after each run" do
      @engine.setup_wanted_times

      # 1st run
      @engine.save_courts({"Thursday, 21 Nov" => ["8:00pm"]})
      @engine.courts_to_notify
      @engine.user_notified

      # 2nd run
      @engine.save_courts({"Thursday, 21 Nov" => ["7:00pm","8:00pm"]})
      @engine.courts_to_notify.should == {"Thursday, 21 Nov" => ["7:00pm"]}
    end
  end
end
