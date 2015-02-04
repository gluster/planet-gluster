require 'nokogiri'
require 'open-uri/cached'

def rewrite_uris html, base
  begin
    doc = Nokogiri::HTML(html)
    base_uri = URI.parse(base)

    tags = {
      a: 'href',
      img: 'src',
      script: 'src'
    }

    doc.search(tags.keys.join(',')).each do |node|
      href = tags[node.name.to_sym]
      orig_url = node[href]
      uri = URI.parse(orig_url)

      unless uri.host
        node[href] = if uri.path.to_s.match(/^\//)
          "#{base_uri.scheme}://#{base_uri.host}#{orig_url}"
        else
          base.gsub(/\/$/, '') + '/' + orig_url
        end
      end
    end

    return doc.to_html
  rescue
    puts "Warning: Issues rewriting URIs (content may still work): #{base}"
    return html
  end
end


def planet_feeds
  return $PLANET_FEEDS if $PLANET_FEEDS

  all_feed_entries = []

  if data[:feeds] # ensure data/feeds.yml exists

    data.feeds.each do |name, info|
      feed_url = info[:feed]

      p info

      begin
        feed = Feedjira::Feed.parse(open(feed_url).read)
        entries = feed.entries

        all_feed_entries += entries.each do |item|
          # Add feed's title & url to each item
          #item[:feed_title] = feed.title
          item[:feed_title] = name || feed.title
          item[:feed_url] = feed.url
          item[:feed_image] = info[:image]
          item[:image_rounded] = info[:rounded]
        end
      rescue
        puts "Error loading #{feed_url}"
      end
    end

  end

  $PLANET_FEEDS = all_feed_entries.reject {|e| e.published.nil? || e.id.match(/archives/)}.sort_by {|e| e.published}.uniq {|e| e.url}.reverse
end
