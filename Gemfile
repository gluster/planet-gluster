# If you have OpenSSL installed, we recommend updating
# the following line to use "https"
source 'http://rubygems.org'
source 'https://rails-assets.org'

gem "middleman", "~> 3.3.3"

gem "middleman-livereload"
gem 'middleman-sprockets'
gem 'middleman-deploy'

# favicon support (favicon PNG should be 144×144)
gem "middleman-favicon-maker"


# Cross-templating language block fix for Ruby 1.8
platforms :mri_18 do
  gem "ruby18_source_location"
end

# For faster file watcher updates for people using Windows
gem "wdm", "~> 0.1.0", :platforms => [:mswin, :mingw]


#####
# General plugins

# HTML & XML parsing smarts
gem "nokogiri"

# Syntax highlighting
gem "middleman-syntax"

# For feed.xml.builder
gem "builder"

# Better JSON lib
gem "oj"

# Lock jQuery to 1.x, for better IE support (6 - 8)
# Fixes and features are backported from 2.x to 1.x; only diff is IE support.
# see http://blog.jquery.com/2013/01/15/jquery-1-9-final-jquery-2-0-beta-migrate-final-released/
gem 'rails-assets-jquery', '~> 1'


#####
# Bootstrap

# Bootstrap, as SASS
gem "bootstrap-sass"


#####
# Formats

gem "coderay"
gem "stringex"

# Markdown
gem "kramdown"

gem 'open-uri-cached'

gem 'font-awesome-middleman'

# RSS/Atom parsing
gem "feedjira"

# HTML sanitization
gem 'sanitize'
