require 'rubygems'
require 'feedzirra'
require 'sinatra'

get '/' do
    
  cache_control :public, max_age: 1800
  
  feed = Feedzirra::Feed.fetch_and_parse("http://fastcolabs.com/rss.xml")
  items = feed.entries.first(20)
  supertags = ["Target", "Open Company", "Accelerator", "Tracking", "Future Of Retail", "Technology"]
  cats = []
  topics = []
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
  erb :index, :locals => {:topics => topics}
end