require 'sinatra'
require 'rubygems'
require 'data_mapper'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'aws/s3'
require 'dotenv'

Dotenv.load

SITE_TITLE = "Img Hub"
SITE_DESCRIPTION = "Host them here, use them anywhere."

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/main.db")

class Image
  include DataMapper::Resource
  property :id, Serial
  property :caption, String
  property :description, Text
  property :picture, String
  property :created_at, DateTime
  property :updated_at, DateTime

  # validate :picture_size
  # TODO: Find out validation for sinatra

  private
    # def picture_size
    #   if picture.size > 5.megabytes
    # 		error.add(:picture, "should be less than 5MB")
    # 	end
    # end
end

DataMapper.auto_upgrade!

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def upload(filename, file)
    bucket = ENV['S3_BUCKET']
    AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['ACCESS_KEY_ID'],
      :secret_access_key => ENV['SECRET_ACCESS_KEY']
    )
    AWS::S3::S3Object.store(
      filename,
      open(file.path),
      bucket
    )
    return filename
  end
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
  # n = Note.new
  # n.attributes = {
  #   :content => params[:content],
  #   :created_at => Time.now,
  #   :updated_at => Time.now
  # }
  if n.save
    redirect '/', :notice => 'Note created successfully.'
  else
    redirect '/', :error => 'Failed to save note.'
  end
end

post '/upload' do
  upload(params[:content]['file'][:filename], params[:content]['file'][:tempfile])
  redirect '/'
end
