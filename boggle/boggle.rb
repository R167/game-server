#!/usr/bin/env ruby -w

class Boggle
  def self.letter
    r = rand
    run = 0
    STATS.each {|l, p| run += p; return l if r < run}
  end
  
  VOWELS = %w{a e i o u}.freeze
  STATS = {"a"=>0.10656619418454816, "l"=>0.05726371225278727, "i"=>0.06781892542999608, "m"=>0.032069023474704465, "n"=>0.05831699254860216, "r"=>0.07010476777410499, "o"=>0.06462546921396156, "u"=>0.04592414140848227, "b"=>0.026612135133620932, "c"=>0.0356490559695221, "y"=>0.028976413244439465, "k"=>0.01886380189366351, "s"=>0.05328029581489159, "f"=>0.014549834724634433, "t"=>0.055504510056585805, "e"=>0.10480699198834668, "d"=>0.03478626253571629, "g"=>0.026186340971482997, "h"=>0.02878592638243039, "v"=>0.009742842736287748, "z"=>0.005165555493304947, "p"=>0.02969914280912096, "j"=>0.004431620819093506, "w"=>0.014471398957924814, "x"=>0.004168300745139784, "q"=>0.0016303434366070927}
  ALPHABET = ('a'..'z').to_a.freeze
  WORDS = File.read(File.join(File.dirname(__FILE__), "words.txt")).split("\n")
  
  def initialize
    @letters = 10.times.map {Boggle.letter}
    @entries = []
  end
  
  def run
    # puts "Words must be at least 3 letters long and you get an additional point for every extra letter"
    # print "\x1b[2J\x1b[1;1H"
    puts "Get ready to play Boggle!"
    puts "Letters to choose from:\n#{@letters * ' '}"
    loop do
      print "Enter a word or -1 to quit: "
      entry = sanatize STDIN.gets.chomp
      if entry == "-1"
        break
      elsif entry.length >= 3 && entry.length <= 6
        @entries << {word: entry, points: (valid_entry?(entry) ? 1 : -2)}
      else
        puts "Entries must be at least 3 letters long and no more than 6."
      end
    end
    @entries.uniq!
    @entries.each do |entry|
      puts entry.map {|k,v| "#{k.to_s[0].upcase}#{k.to_s[1..-1]}: #{v}"} * ' | '
    end
    puts "Points earned: #{earned}"
    puts "Points lost: #{lost}"
    puts "Points total: #{total}"
  end
  
  def valid_entry?(str)
    copy = @letters.dup
    sanatize(str).each_char do |c|
      return false unless copy.delete_at(copy.index(c) || copy.length)
    end
    has_word?(str) >= 0
  end
  
  def has_word?(word)
    min = 0
    max = WORDS.length - 1
    while min <= max
      pivot = min + (max - min) / 2
      if (word <=> WORDS[pivot]) < 0
        max = pivot - 1
      elsif (word <=> WORDS[pivot]) > 0
        min = pivot + 1
      else
        return pivot
      end
    end
    -1
  end
  
  def sanatize(str)
    str.strip.downcase
  end
  
  def total
    if @entries.any?
      @entries.map{|h| h[:points]}.inject(:+)
    else
      0
    end
  end
  
  def lost
    if @entries.any?
      -@entries.map{|h| h[:points] < 0 ? h[:points] : 0}.inject(:+)
    else
      0
    end
  end
  
  def earned
    if @entries.any?
      @entries.map{|h| h[:points] > 0 ? h[:points] : 0}.inject(:+)
    else
      0
    end
  end
end

if __FILE__ == $0
  STDOUT.sync = true
  Boggle.new.run
end
