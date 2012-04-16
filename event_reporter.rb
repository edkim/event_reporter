# Dependencies
require "csv"

#Questions
  #How do I ignore the first column? Can I access 
  #


# Class Definition
class EventReporter	

  def initialize
    puts "EventReporter Initialized."
    filename = "event_attendees.csv"
    @file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
  end


  #lifted from JSTwitter
  def run
    command = ""
    while command != "q"
      puts ""
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 'print' then print_names
        when 'printa' then print_all
        when 'printh' then print_headers
        else puts "Sorry, I don't know how to #{command}"
      end     
    end
  end


  def print_headers    
    #puts @file.gets.each.headers 
    
    @file.gets.each do |header, data|
      printf header.to_s + "\t"
    end
    # how do i insert tabs between headers?
  end


  def print_names
    @file.each do |line|
      puts line[:first_name] + "\t" + line[:last_name]
    end

    @file.rewind
  end

  def print_all
    @file.each do |line|
      line.each do |header, data|
        printf data + "\t" #breaks when it hits null zip code
      end
      puts
    end

    @file.rewind
  end


  #
  # All Methods below are unmodified from EventManager
  #
  def print_numbers
  	@file.each do |line|
  		number = line[:homephone]
  		clean_number = number.delete(".")
  		clean_number = clean_number.delete(" ")
  		clean_number = clean_number.delete("-")
  		clean_number = clean_number.delete("(")
  		clean_number = clean_number.delete(")")
  		puts clean_number
	 end
  end

  def clean_number(original)
  	  	@file.each do |line|
  		number = line[:homephone]
  		clean_number = number.delete(".")
  		clean_number = clean_number.delete(" ")
  		clean_number = clean_number.delete("-")
  		clean_number = clean_number.delete("(")
  		clean_number = clean_number.delete(")")
  		return clean_number
	end
  end

   def rep_lookup
    20.times do
      line = @file.readline

      representative = "unknown"
      # API Lookup Goes Here
      legislators = Sunlight::Legislator.all_in_zipcode('02806')
		

	  names = legislators.collect do |leg|
		first_name = leg.firstname
		first_initial = first_name[0]
		last_name = leg.lastname
		first_initial + ". " + last_name
	  end
	  puts "#{line[:last_name]}, #{line[:first_name]}, #{line[:zipcode]}, #{names.join(", ")}"

    end
  end

  def output_data
    output = CSV.open("event_attendees_clean.csv", "w")
    @file.each do |line|
      if @file.lineno == 2
      	output << line.headers
      else 
      	line[:homephone] = clean_number(line[:homephone])
      	output << line
      end
    end
  end
end

# Script
reporter = EventReporter.new
reporter.run

