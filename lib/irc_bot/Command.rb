require 'socket'

#Experiment: push Chat without Javascript.

begin
  require 'daemons'
rescue LoadError
  raise "You need to add gem 'daemons' to your Gemfile if you wish to use it."
end

module IrcBot
  class IrcClient
    def initialize
      @bot = Cinch::Bot.new do
        configure do |c|
          c.server = ''
          c.channels = [""]
          c.nick = ""
          c.reconnect = true
        end

        on :message, /^!msg (.+?) (.+)/ do |m, who, text|
          User(who).send text
        end
      end

      @bot.start
    end
  end

  class CometServer
    def initialize
      @clients = []
    end

    def accept_connections
      server = TCPServer.open(2000)
      puts "Server open on port 2000"
      loop do
        puts "Waiting..."
        client = server.accept # Wait for a client to connect
        client.puts "HTTP/1.1 200 OK"
        client.puts "Content-Type: text/html"
        client.puts "Content-Length: 10000000"
        client.puts ""
        client.puts "<!DOCTYPE html>"
        client.puts "<html lang=\"en\">"
        client.puts "<head>"
        client.puts "<meta charset=\"utf-8\"/>"
        client.puts "</head>"
        client.puts "<body>"

        while true do
          client.puts("#{DateTime.now.to_s} <strong id=\"test\">Test</strong>: I have a message for you <br>") # Send the time to the client
          sleep 2
        end
        client.close # Disconnect from the client
      end
    end

    def client_loop
      loop do
        puts "Client loop"
        ready = IO.select(@clients)
        puts "Client selected"
        ready.each do |client|
          client.puts 'test'
        end
        sleep 5
      end
    end
  end

  class Command
    def initialize(args)
      @irc = IrcClient.new
      puts "HERE"
      @comet = CometServer.new
    end

    def run
      # Daemons.daemonize

      # Thread.new do
      #  client_loop()
      # end

    end
  end
end
