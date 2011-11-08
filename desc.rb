require 'csv'
require 'stemmer'

class Bingo
  attr_accessor :hotlist, :notlist, :doc, :list, :counts, :sorted, :dictionary, :per_project_list
  
  def initialize
    @doc = CSV.read('input.csv')
    @hotlist = %w(better biodiversity build capacity capacity\ building collaborate create
                  data database dataset enable enhance facilitate faster global
                  harmonisation harmonise harmonised harmonized implement improve improved increased\ investment
                  integrate integrated integration linkages lower\ cost
                  mainstream national network nexus partnership partnerships poverty provide report reporting share
                  simpler streamline streamlinined streamlining support supported supporting understand understanding
                )
     @notlist = %w(the of to has into usd for on in a and 
     it is by was this be an as are from at that 
     which these their other unep wcmc about above again)
     all_counts
  end
  
  def hotlist_counts
    @doc.shift
    list = []
    @doc.each{|line| line[4].split(/[^a-zA-Z]/).each{|word| if @hotlist.include?(word.downcase) then list << word.downcase end}}
    counts = {}
    list.uniq.each{|item| counts[item] = 0}
    list.each{|item| counts[item] += 1}
    sorted = counts.sort {|a,b| b[1]<=>a[1]}
    sorted.each{|item| puts "#{item[1]} -- #{item[0]}"}
  end
  
  def all_counts
    @doc.shift

    @list = []
    @per_project_list = []
    @doc.each do |line|
      line[4].split(/[^a-zA-Z]/).each do |word|
        word = word.downcase      
        if !@notlist.include?(word) && word != "null" && word !=""
          @list << word
          if !@per_project_list.include?(word)
            @per_project_list << word
          end
        end
      end
    end

    # Comment out next line if you want the number of occurrences rather than number of projects
    @list = @per_project_list
      
    unique_stems = []
    @dictionary = {}
    # list_unique = []

    @list.each do |word|
      unless unique_stems.include?(word.stem) 
        then unique_stems << word.stem 
        dictionary[word.stem] = word
      end
    end
    # puts dictionary
    
    @counts = {}
    unique_stems.each{|stem| @counts[stem] = 0}
    @list.each do |item|
      short = item.stem
      @counts[short] += 1
    end
    
    @sorted = @counts.sort {|a,b| b[1]<=>a[1]}
        
  end
  
  def export
    CSV.open("output.csv", "w") do |csv|
      @sorted.each do |line|
        csv << [dictionary[line[0]],line[1]]
      end
    end
    puts "saved"
  end
end

Bingo.new.export
