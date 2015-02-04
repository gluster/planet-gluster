xml.instruct!
xml.opml version: '1.1' do

  modified_time = IO.popen(["git", "log", "--pretty=format:%ai", "#{root}/data/feeds.yml"]).read.split(/\n/).first.to_date rescue Time.now

  xml.head do
    xml.title data.site.name
    xml.dateModified modified_time.to_s( :rfc822 ).strip
    xml.ownerName { xml.name data.site.owner || data.site.name }.strip
  end

  feed_map = {}
  title_map = {}

  planet_feeds.each do |info|
    next if feed_map[info[:feed_source]]
    feed_map[info[:feed_source]] = info[:feed_url]
    title_map[info[:feed_source]] = info[:feed_title]
  end

  xml.body do
    data.feeds.each do |name, info|
      xml.outline text: name.strip,
        type: 'rss',
        title: title_map[info[:feed].strip],
        htmlUrl: feed_map[info[:feed].strip],
        xmlUrl: info[:feed].strip
    end
  end
end
