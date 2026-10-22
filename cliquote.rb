#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'io/console'

QUOTES_URI = URI('http://clearquot.es/quotes.json')

def fetch_quotes
  response = Net::HTTP.start(QUOTES_URI.host, QUOTES_URI.port,
                             use_ssl: QUOTES_URI.scheme == 'https',
                             open_timeout: 5, read_timeout: 5) do |http|
    http.get(QUOTES_URI.request_uri)
  end
  raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body).fetch('quotes')
end

def terminal_width
  IO.console&.winsize&.last.to_i.nonzero? || 80
end

def wrap(text, width)
  text.gsub(/(.{1,#{width}})(\s+|\z)/, "\\1\n").rstrip
end

begin
  quote = fetch_quotes.values.sample
  width = terminal_width

  puts
  puts wrap(quote['quote'], width - 4).lines.map { |l| "  #{l}" }.join
  puts
  puts "-- #{quote['author']}".rjust(width - 2)
rescue StandardError => e
  warn "cliquote: não foi possível obter uma citação (#{e.message})"
  exit 1
end
