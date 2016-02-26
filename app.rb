# encoding: utf-8
require "rubygems"
require "sinatra"
require "open-uri"
require "rss"
require "simple-rss"

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
	template = " – http://ift.tt/_______ #ATX"

	items = []
	rss = SimpleRSS.parse open(feed_url)
	rss.entries.each do |entry|
		items.push(entry)
	end

	rss = RSS::Maker.make("atom") do |maker|
		maker.channel.author = "r/Austin"
		maker.channel.updated = Time.now.to_s
		maker.channel.about = "This is not the official r/Austin feed. This is a special version for http://twitter.com/RedditAustin. For the real feed, go to #{feed_url}"
		maker.channel.title = rss.feed.title

		items.each do |r_item|
			maker.items.new_item do |item|
				max_length = 140-omission.length-template.length
				title = r_item.title.encode('UTF-8', {
					:invalid => :replace,
					:undef   => :replace,
					:replace => ''
				})
				item.link = r_item.link
				item.title = chop(title, length: max_length, omission: omission)
				item.updated = r_item.updated.to_s
			end
	  end
	end

	rss.to_s
end
