module AutomateAT
  class Scraper
    
    def initialize(raw_data)
      @raw_data = raw_data
    end
    
    def get_available_courts
      data = @raw_data.xpath('//tr')[1..16]
      dates = get_bookable_dates(@raw_data)
      
      availability = data.inject({}) do |result, row|
        clean_data = row.css('td')
        time = row.css('th')[0].text
                
        dates.each_with_index do |date, i|
          if clean_data[i].text =~ /Left/
            result[date] = [] if result[date].nil?
            result[date] << time 
          end
        end
        result
      end
      availability
    end
  
    def get_bookable_dates(data)
      row_of_dates = data.xpath("//tr[1]/th")
      dates = row_of_dates.inject([]) do |result, cell|
        if cell.content != "Time"
          date = cell.children[0].text + ", " + cell.children[2]
          result << date
        end
        result
      end
      dates
    end
  end
end