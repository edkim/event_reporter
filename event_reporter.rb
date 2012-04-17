# Dependencies
require "csv"

#Questions
  #How do I ignore the first column?
  #Can I print column + "\t" in a loop?
  #How to have help method with default "event_attendees.csv" parameter

# Class Definition
class EventReporter	
  INVALID_ZIPCODE = "00000"

  def initialize
    puts "EventReporter Initialized."
    @queue = []
  end


  
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
        when 'load' then load #add optional parameter        
        when 'queue' then queue_actions(parts[1])
        when 'find' then find(parts[1], parts[2])      
        when 'help' then help(parts[1..-1]) #pass add'l parameters
        else puts "Sorry, I don't know how to #{command}"
      end     
    end
  end


  def load(filename="event_attendees.csv")
    @file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
    @clean_filename = "#{filename}".sub(".csv", "") + "_clean.csv"
    cleanup_data    
    @clean_file = CSV.open(@clean_filename, {:headers => true, :header_converters => :symbol})
    puts "File loaded"
  end


  def printline(line)
    printf line[:first_name] + "\t"
    printf line[:last_name] + "\t"
    printf line[:email_address] + "\t"
    printf line[:homephone] + "\t"
    printf line[:street] + "\t"
    printf line[:city] + "\t"
    printf line[:state] + "\t"
    printf line[:zipcode] + "\n"
  end


  def queue_actions(action)
    case action
      when 'count' then puts @queue.count
      when 'print' then queue_print
      when 'clear' then queue_clear
      else puts "Sorry I don't understand how to queue #{action}"
    end
  end

  def queue_print
    if @queue.empty? 
      puts "Queue is empty"    
    else
      print_headers
      @queue.each do |line|
        printline(line)
      end
    end
  end


  def queue_load(line)
    @queue << line
  end

  def queue_clear
    @queue = []
  end  

  def find(attribute, criteria)
    # Load the queue with all records matching the criteria for the given attribute. Example usages:
      # find zipcode 20011
      # find last_name Johnson
      # find state VA
    queue_clear
    if @clean_file.nil? 
      puts "Please load file first"
    else 
      @clean_file.each do |line|  
        if line[attribute.to_sym].strip.upcase == criteria.upcase
          printline(line)
          queue_load(line)
        end
      end
      @clean_file.rewind
    end
  end



  def cleanup_data
    output = CSV.open(@clean_filename, "w")
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

  def print_headers   
    #Is there a better way to start printing at first_name?
    @clean_file.gets.each do |header, data|
      printf header.to_s + "\t" if header != :regdate && header!= :_
    end
    puts
  end

  #How do I pass a method to override default?
  def help(keywords=[])    
    if keywords==[]
      puts "Available commands:"
      puts "-load"
      puts "-queue count"
      puts "-queue print"
      puts "-queue clear"
      puts "-find <attribute> <criteria>"
      puts "\nFor more help with commands, try help <command>. Ex. 'help queue count'"
    elsif keywords[1] == "count" then 
      puts "queue count - prints out the number of rows"
    elsif keywords[1] == "print" then 
      puts "queue print - prints out the entire queue"
    elsif keywords[1] == "clear" then 
      puts "queue clear - clears the queue"
    elsif keywords[0] == "find" then 
      puts "find <attribute> <criteria> - loads the queue with all records"
      puts "matching the criteria for the given attribute"
    else puts "Sorry I don't know what you mean"
    end
  end    

end

# Script
reporter = EventReporter.new
reporter.run

