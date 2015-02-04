xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = data.site.domain[/http:/] ? data.site.domain : "http://#{data.site.domain}"
  xml.title data.site.name
  #xml.subtitle data.site.subtitle
  xml.subtitle defined?(tag_name) ? "Tag: #{tag_name.titleize}" : nil
  xml.id site_url
  xml.link "href" => site_url
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.updated planet_feeds.first.published.to_time.iso8601
  xml.author { xml.name data.site.owner }

  # Optionally filter by tag
  relevant_entries = if defined? tag_name
    planet_feeds.select do |a|
      tags = a.data.tags
      # Convert CSV string to an array, else use an array
      tags = tags.parse_csv.map{|s| s.strip} if tags.class == String
      tags && tags.detect {|t| t.downcase == tag_name.downcase}
    end
  else
    planet_feeds
  end

  relevant_entries.take(50).each do |entry|
    #nickname = entry.data.author
    p entry

    xml.entry do
      xml.title entry.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, entry.url)
      xml.id URI.join(site_url, entry.url)
      xml.published entry.published #.to_time.iso8601
      xml.updated entry.updated || entry.published #.to_time.iso8601 #File.mtime(entry.source_file).iso8601
      xml.author entry.author || entry[:feed_title]
      #xml.summary demote_headings(entry.summary), "type" => "html"
      xml.content demote_headings(rewrite_uris((entry.content || entry.summary), entry['feed_url'])), "type" => "html"
    end
  end
end
