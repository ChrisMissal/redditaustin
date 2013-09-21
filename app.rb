# encoding: utf-8
require "rubygems"
require "sinatra"
require "open-uri"
require "rss"

helpers do
	def chop(text, options = {}, &block)
	  if text
	  	length = options.fetch(:length)
	  	omission = options.fetch(:omission, '...')
	    return text unless text.length > length

	    text.slice(0, length) + omission
	  end
	end
end

get '/' do
	'<a href="http://twitter.com/RedditAustin">@RedditAustin</a>'
end

get '/rss', :provides => ['rss', 'atom', 'xml'] do
	feed_url = 'http://www.reddit.com/r/austin.rss'
	omission = "..."
	template = " – http://bit.ly/_______ #Austin"

	feed = nil
	items = []
	open(feed_url) do |rss|
		feed = RSS::Parser.parse(rss)
		feed.items.each do |item|
			items.push(item)
		end
	end

	puts feed

	rss = RSS::Maker.make("atom") do |maker|
	  maker.channel.author = "r/Austin"
	  maker.channel.updated = Time.now.to_s
	  maker.channel.about = "This is not the official r/Austin feed. This is a special version for http://twitter.com/RedditAustin. For the real feed, go to #{feed_url}"
	  maker.channel.title = feed.channel.title

	  items.each do |r_item|
		  maker.items.new_item do |item|
		  	max_length = 140-omission.length-template.length
		    item.link = r_item.link
		    item.title = chop(r_item.title, length: max_length, omission: omission)
		    item.updated = r_item.pubDate.to_s
		  end
		end
	end

	rss.to_s
end
