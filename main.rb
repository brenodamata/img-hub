require 'sinatra'
require 'rubygems'
require 'data_mapper'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

SITE_TITLE = "Img Hub"
SITE_DESCRIPTION = "Host them here, use them anywhere."

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/home.db")

class Image
  include DataMapper::Resource
  property :id, Serial
  property :caption, String
  property :description, Text
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.auto_upgrade!

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

#
# Application
#

get '/' do
  @images = Image.all :order => :id.desc
  @title = 'All Images'
  if @images.empty?
    flash[:error] = 'No images found. Upload below.'
  end
  erb :home
end

post '/' do
  n = Note.new
  n.attributes = {
    :content => params[:content],
    :created_at => Time.now,
    :updated_at => Time.now
  }
  if n.save
    redirect '/', :notice => 'Note created successfully.'
  else
    redirect '/', :error => 'Failed to save note.'
  end
end

get '/about' do
  erb :about
end
