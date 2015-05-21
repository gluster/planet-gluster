require 'nokogiri'
require 'open-uri/cached'
require 'net/http'

# Fix the URIs in HTML to use absolute links instead of relative ones,
# falling back to original HTML if unsuccessful
def rewrite_uris(html, base)
  doc = Nokogiri::HTML(html)
  base_uri = URI.parse(base)

  tags = {
    a: 'href',
    img: 'src',
    script: 'src'
  }

  doc.search(tags.keys.join(',')).each do |node|
    href     = tags[node.name.to_sym]
    orig_url = node[href]
    uri      = URI.parse(orig_url)

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

# Grab head of a URL
def http_head(url)
  u = URI.parse(url)
  Net::HTTP.start(u.host, u.port).head(u.request_uri)
rescue
  puts "ERR:  Problem getting HTTP HEAD of '#{url}'; site down or cert issue?"
end

# Download Atom/RSS feed, with error handling and HTTP → HTTPS fallback
def download_feed(feed_url, time_ago = nil)
  OpenURI::Cache.invalidate(feed_url, Time.now - time_ago.to_i) if time_ago
  request = open(feed_url)
  request.read
rescue
  if feed_url.match(/http:/)
    feed_url_secure = feed_url.sub('http:', 'https:')
    download_feed(feed_url_secure, time_ago)
    puts "WARN: Switch #{feed_url} to HTTPS in data/feeds.yml"
  else
    head = http_head(feed_url)
    err_msg = "HTTP #{defined?(head.code) ? head.code : 'unknown error'}"
    puts "ERR:  #{err_msg}: Problem downloading '#{feed_url}'"
    nil
  end
ensure
  request.close if request
end

# Parse the feed, with a fallback message as to why it might not work
def parse_feed(feed_raw, feed_url = 'unknown feed')
  Feedjira::Feed.parse(feed_raw) unless feed_raw.to_s == ''
rescue
  head = http_head(feed_url)
  err_msg = "Server sent '#{head.content_type}'"
  puts "ERR:  #{err_msg}; problem parsing '#{feed_url}'"
  nil
end


def planet_feeds
  return $PLANET_FEEDS if $PLANET_FEEDS

  # Time to force a planet feed re-fetch; 6 hours by default
  # Configurable in data/site.yml; see "planet_refresh"
  time_ago = (data.site['planet_refresh'] || 6) * 3600

  all_feed_entries = []

  if data[:feeds] # ensure data/feeds.yml exists

    data.feeds.each do |name, info|
      feed_url = info[:feed]

      next unless feed_url

      feed_raw = download_feed(feed_url, time_ago)
      next unless feed_raw

      feed = parse_feed(feed_raw, feed_url)
      next unless feed

      all_feed_entries += feed.entries.each do |item|
        # Add feed's title & url to each item
        item[:feed_name]     = name
        item[:feed_title]    = feed.title || name
        item[:feed_url]      = feed.url
        item[:feed_source]   = feed_url
        item[:feed_image]    = info[:image]
        item[:image_rounded] = info[:rounded]
      end
    end

  end

  $PLANET_FEEDS = all_feed_entries
                  .reject  { |e| e.published.nil? || e.id.match(/archives/) }
                  .sort_by { |e| e.published }
                  .uniq    { |e| e.url }
                  .reverse
end
