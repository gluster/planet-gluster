#!/usr/bin/ruby

require 'nokogiri'
require 'yaml'

begin

  doc = Nokogiri::XML(ARGF.read)

  info = {}

  doc.css('outline').each do |site|
    info[ site[:text] ] = {
      "feed"  => site[:xmlUrl],
      "title" => site[:title],
      "site"  => site[:htmlUrl]
    }.reject {|key, val| val.nil? || val.empty? }
  end

  puts info.to_yaml.gsub(/^[^\s].*:/, "\n\\0").gsub(/^---$/, '').strip

rescue
  puts "There was an error processing your OPML."
end
