require 'httparty'
require 'nokogiri'


page = HTTParty.get('http://espn.go.com/mlb/freeagents')

parse_page = Nokogiri::HTML(page)

rows = parse_page.css(".tablehead tr:gt(3)")

details = rows.collect do |row|
  detail = {}
  detail1 = []
  detail2 = {}
 
  detail2["old_team"] = row.css('td[5]/text()').to_s 
  detail2["new_team"] = row.css('td[6]/text()').to_s
  detail1 << detail2

  detail[(row.css('a/text()').to_s)] = detail1
  detail
  end
end
current_team = Hash.new{|h,k| h[k] = []}
details.each do |item|
  item.each do |key, value|
    value.each do |team|
      if team["new_team"] !~ /[A-Z][a-z]+/
        if key == ""
          next
        else
          # puts "#{key} has not been signed yet"
          current_team[key] << team["old_team"]
          current_team[key] << "unsigned" 
        end
      elsif team["old_team"] == team["new_team"]
        # puts "#{key} has not changed teams and is still with #{team["old_team"]}"
        current_team[key] << team["old_team"]
        current_team[key] << "old"       
      else
        # puts "#{key} has changed teams from #{team["old_team"]} to #{team["new_team"]}"
        current_team[key] << team["new_team"]
        current_team[key] << "new"
      end
    end
  end
end 