require 'rubygems'
require 'feedzirra'
require 'sinatra'
require 'dalli'
require 'memcachier'

set :cache, Dalli::Client.new
set :enable_cache, true
set :short_ttl, 400
set :long_ttl, 1800

get '/' do
  supertags = ["Target", "Open Company", "Accelerator", "Tracking", "Future Of Retail", "Technology"]
  cats = []
  topics = []
  feed = getFeed()
  if(feed)
    items = feed.entries.first(20)
    items.each do |i|
      i.categories.each do |c|
        if supertags.include? c
          break
        end
        if !cats.include? c
          topic = { :cat => c, :url => i.url, :title => i.title }
          topics.push(topic)
          cats.push(c)
          # break
        end
      end
    end
  else
    topics.push({ :cat => 'Feed down. Check back momentarily.', :url => 'http://fastcolabs.com', :title => 'Feed down'})
  end
  erb :index, :locals => {:topics => topics}
end

def getFeed(time_to_live = settings.long_ttl)
  if(!settings.enable_cache)
    return Feedzirra::Feed.fetch_and_parse("http://fastcolabs.com/rss.xml")
  end
  if(settings.cache.get('feed') == nil)
    settings.cache.set('feed', Feedzirra::Feed.fetch_and_parse("http://fastcolabs.com/rss.xml"), ttl=time_to_live+rand(100))
  end
 
  return settings.cache.get('feed')
end