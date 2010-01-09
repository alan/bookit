module AutomateAT
  class Scrapper
    
    def initialize(raw_data)
      @raw_data = raw_data
    end
    
    def get_available_courts
      data = @raw_data.xpath('//tr')
      dates = get_bookable_dates(@raw_data)
      
      availability = data.inject({}) do |result, row|
        clean_data = row.css('td')
        time = clean_data.delete(clean_data.first).text
      
        dates.each_with_index do |date, i|
          if clean_data[i].text =~ /Left/
            result[date] = [] if(result[date].nil?)
            result[date] << time 
          end
        end
        result
      end
      availability
    end
  
    def get_bookable_dates(data)
      row_of_dates = data.xpath("//tr[1]/td")
      dates = row_of_dates.inject([]) do |result, cell|
        if cell.content != "Time"
          date = cell.children[0].text + ", " + cell.children[2]
          result << date
        end
        result
      end
      dates
    end
    
    private
    
    def redis_db
      AutomateAT.redis_db
    end
  end
end