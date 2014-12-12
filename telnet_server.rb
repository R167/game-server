#!/usr/bin/env ruby

require 'socket'
# require 'json'

module GameServer
  GAMES = [
    {
      :name => "Boggle",
      :exec => "ruby boggle/boggle.rb"
    }
  ].freeze
  
  class Server
    PORT = 9000
    
    def initialize(port=nil)
      @server = TCPServer.new(port || PORT)
      @server.setsockopt(:SOCKET, :REUSEADDR, true)
      @lock = Mutex.new
      # refresh_games
    end

    def serve
      Socket.accept_loop(@server) do |connection|
        Thread.new do
          begin
            loop do
              connection.print "Would you like to play a game? [Y/n] "
              play = connection.gets.chomp.strip.downcase
              break if play[0] == 'n'
              GAMES.each_with_index {|e, i| connection.puts "#{i + 1}). #{e[:name]}"}
              game = nil
              loop do
                connection.print "What game would you like to play? "
                choice = connection.gets.chomp.strip.downcase
                if choice.to_i >= 1 && choice.to_i <= GAMES.length
                  puts GAMES.inspect
                  game = GAMES[choice.to_i - 1]
                  break
                end
                games = find_game(choice)
                if games.length == 1
                  game = games[0]
                  break
                elsif games.length > 1
                  connection.puts "You'll need to be more specific than that..."
                else
                  connection.puts "No such game!"
                end
              end
              puts "Going to run"
              run_game(game, connection)
            end
            connection.puts "Goodbye!"
          rescue => e
            puts e.inspect
          ensure
            puts "WTF"
            connection.close
          end
        end
      end
    end
    
    def refresh_games
      @lock.synchronize do
        open("games_list.json") {|f| @games = JSON.parse(f.read)}
        @games
      end
    end
    
    def run_game(game, connection)
      connection.print "\n#{'=' * 10} Starting #{game[:name]} #{'=' * 10}\n\n"
      pid = Process.spawn(game[:exec], :in => connection.to_io, :out => connection.to_io)
      Process.wait(pid)
      connection.print "\n"
    end
    
    def find_game(game)
      # games = refresh_games
      GAMES.map{|n| n if n[:name].downcase.match(game)}.compact
    end
  end
end

if __FILE__ == $0
  GameServer::Server.new.serve
end
