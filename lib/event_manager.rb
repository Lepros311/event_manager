require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

puts 'Event Manager Initialized!'

# template_letter = File.read('form_letter.html')
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

# contents = File.read('event_attendees.csv')
# puts contents

# lines = File.readlines('event_attendees.csv')
# lines.each_with_index do |line, index|
#   # puts line
#   next if index == 0
#   columns = line.split(",")
#   name = columns[2]
#   # p columns
#   puts name
# end

# contents = CSV.open('event_attendees.csv', headers: true)

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

# contents.each do |row|
#   name = row[2]
#   puts name
# end

def clean_zipcode(zipcode)
  # if zipcode.nil?
  #   zipcode = '00000'
  # elsif zipcode.length < 5
  #   zipcode = zipcode.rjust(5, '0')
  # elsif zipcode.length > 5
  #   zipcode = zipcode[0..4]
  # end
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    # legislators = civic_info.representative_info_by_address(
    #   address: zip,
    #   levels: 'country',
    #   roles: ['legislatorUpperBody', 'legislatorLowerBody']
    # )
    # legislators = legislators.officials

    # # legislator_names = legislators.map do |legislator|
    # #   legislator.name
    # # end

    # legislator_names = legislators.map(&:name) # same as commented lines above

    # legislators_string = legislator_names.join(", ")

    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials

  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  # zipcode = row[:zipcode]
  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  # personal_letter = template_letter.gsub('FIRST_NAME', name)
  # personal_letter.gsub!('LEGISLATORS', legislators)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)

  # puts personal_letter

  # puts form_letter

  # puts "\n#{name} #{zipcode} #{legislators}"
end
