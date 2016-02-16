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

current_team = Hash.new{|h,k| h[k] = []}
details.each do |item|
  item.each do |key, value|
    value.each do |team|
      if team["new_team"] !~ /[A-Z][a-z]+/
        #eliminates column title rows from output
        if key == ""
          next
        else
          # addresses players that have not signed with a team
          team["old_team"] =~ /[A-Z][a-z]+/ ? current_team[key] << team["old_team"] : current_team[key] << "Unaffiliated"
          current_team[key] << "unsigned" 
        end
      elsif team["old_team"] == team["new_team"]
        # addresses players that re-signed with old team
        current_team[key] << team["old_team"]
        current_team[key] << "old"       
      else
        # addresses players that signed with a new team
        current_team[key] << team["new_team"]
        current_team[key] << "new"
      end
    end
  end
end 

by_team = Hash.new{|h,k| h[k] = []}

current_team.each do |player, team|
  hsh = {}
  hsh[player] = team[1]
  by_team[team[0]] << hsh
 end

temp_list = by_team.sort_by {|squad, other_info| squad}
final_list = Hash[*temp_list.flatten(1)]

output = File.open( "./output.txt","w" )
output << final_list
output.close
system "sed 's/=>/:/g' output.txt > final.txt"
