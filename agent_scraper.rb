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
