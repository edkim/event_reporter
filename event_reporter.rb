# Dependencies
require "csv"

#Questions
  #How do I ignore the first column? Can I access 
  #


# Class Definition
class EventReporter	

  INVALID_ZIPCODE = "00000"

  def initialize
    puts "EventReporter Initialized."
    filename = "event_attendees.csv"
    @file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
    cleanup_data
    clean_filename = "event_attendees_clean.csv"
    @clean_file = CSV.open(clean_filename, {:headers => true, :header_converters => :symbol})
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
        when 'print' then print     
        when 'printh' then print_headers
        else puts "Sorry, I don't know how to #{command}"
      end     
    end
  end


  def print_headers    
    #puts @file.gets.each.headers 
    
    @clean_file.gets.each do |header, data|
      printf header.to_s + "\t"
    end
    # how do i insert tabs between headers?
  end


  #def print_names
   # @file.each do |line|
   #   puts line[:first_name] + "\t" + line[:last_name]
   # end

   # @file.rewind
  #end

  def print
   @clean_file.each do |line|
     printf line[:regdate] + "\t" 
     printf line[:first_name] + "\t"
     printf line[:last_name] + "\t"
     printf line[:email_address] + "\t"
     printf line[:homephone] + "\t"
     printf line[:street] + "\t"
     printf line[:city] + "\t"
     printf line[:state] + "\t"
     printf line[:zipcode] + "\n"
   end
   @file.rewind
  end


  def cleanup_data
    output = CSV.open("event_attendees_clean.csv", "w")
    @file.each do |line|
      if @file.lineno == 2
        output << line.headers
        output << line
      else 
        line[:street] = " " if line[:street].nil?
        line[:city] = " " if line[:city].nil?
        line[:state] = " " if line[:state].nil?        
        line[:homephone] = clean_number(line[:homephone])
        line[:zipcode] = clean_zipcode(line[:zipcode])
        output << line
      end
    end
  end

  
  def clean_zipcode(zipcode)
    if zipcode.nil?
      zipcode = INVALID_ZIPCODE
    elsif
      unless zipcode.length >= 5
        zipcode = "0" + zipcode
      end
    else
      # Do Nothing
    end

    return zipcode
  end


  def print_all_neat
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

  
end

# Script
reporter = EventReporter.new
reporter.run

