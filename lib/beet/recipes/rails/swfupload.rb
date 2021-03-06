# lots of code and ideas borrowed from http://jetpackweb.com/blog/2009/10/21/rails-2-3-4-and-swfupload-rack-middleware-for-flash-uploads-that-degrade-gracefully/
# setup directories to hold files
FileUtils.mkdir_p 'public/javascripts/swfupload'
FileUtils.mkdir_p 'public/flash/swfupload'
FileUtils.mkdir_p 'public/images/swfupload'
FileUtils.mkdir_p 'app/views/swfupload'
FileUtils.mkdir_p 'app/stylesheets'

# download plugin files
base_url = 'http://swfupload.googlecode.com/svn/swfupload/trunk/core/plugins'

js_files = %w(swfupload.cookies swfupload.queue swfupload.speed swfupload.swfobject handlers swfupload)

js_files.each do |js_file|
  run "curl -L #{base_url}/#{js_file}.js > public/javascripts/swfupload/#{js_file}.js"
end

run "curl -L http://github.com/jackdempsey/beet/raw/master/lib/beet/files/swfupload/js/handlers.js > public/javascripts/swfupload/handlers.js"
run "curl -L http://swfupload.googlecode.com/svn/swfupload/trunk/core/swfupload.js > public/javascripts/swfupload/swfupload.js"
run "curl -L http://swfupload.googlecode.com/svn/swfupload/trunk/core/Flash/swfupload.swf > public/flash/swfupload/swfupload.swf"
run "chmod +x public/flash/swfupload/swfupload.swf"
run "curl -L http://github.com/jackdempsey/beet/raw/master/lib/beet/files/swfupload/images/cancelbutton.gif > public/images/swfupload/cancelbutton.gif"

file 'app/stylesheets/swfupload.sass', <<-FILE
divFileProgressContainer
  height: 75px

#divFileProgress

  .progressWrapper
    width: 100%
    overflow: hidden

  .progressContainer
    margin: 5px
    padding: 4px
    border: solid 1px #E8E8E8
    background-color: #F7F7F7
    overflow: hidden
    
  .progressName
    font-size: 8pt
    font-weight: 700
    color: #555
    width: 100%
    height: 14px
    text-align: left
    white-space: nowrap
    overflow: hidden

  .progressBarInProgress, .progressBarComplete, .progressBarError
    font-size: 0
    width: 0%
    height: 2px
    background-color: blue
    margin-top: 2px
    
  .progressBarComplete
    width: 100%
    background-color: green
    visibility: hidden
    
  .progressBarError
    width: 100%
    background-color: red
    visibility: hidden

  .progressBarStatus
    margin-top: 2px
    width: 337px
    font-size: 7pt
    font-family: Arial
    text-align: left
    white-space: nowrap
      
  a.progressCancel
    font-size: 0
    display: block
    height: 14px
    width: 14px
    background-image: url(/images/swfupload/cancelbutton.gif)
    background-repeat: no-repeat
    background-position: -14px 0px
    float: right

  a.progressCancel:hover
    background-position: 0px 0px
FILE

# create upload partial
file 'app/views/swfupload/_upload.html.haml', %q{
- content_for :head do
  = javascript_include_tag 'swfupload/swfupload', 'swfupload/swfupload.swfobject', 'swfupload/handlers'
  = stylesheet_link_tag %w(compiled/swfupload)
- session_key_name = ActionController::Base.session_options[:key]

- upload_url = songs_path
- form_tag upload_url, :multipart => true do
  #swfupload_degraded_container
    %noscript= "You should have Javascript enabled for a nicer upload experience"
    = file_field_tag :Filedata
    = submit_tag "Add a File"
  #swfupload_container{ :style => "display: none" }
    %span#spanButtonPlaceholder
  #divFileProgressContainer


:javascript
  SWFUpload.onload = function() {
    var swf_settings = {

      // SWFObject settings
      minimum_flash_version: "9.0.28",
      swfupload_pre_load_handler: function() {
        $('#swfupload_degraded_container').hide();
        $('#swfupload_container').show();
      },
      swfupload_load_failed_handler: function() {
      },

      post_params: {
        "#{session_key_name}": "#{cookies[session_key_name]}",
        "authenticity_token": "#{form_authenticity_token}",
      },

      //upload_url: "#{upload_url}?#{session_key_name}="+encodeURIComponent("#{cookies[session_key_name]}")+"&authenticity_token="+encodeURIComponent("#{form_authenticity_token}"),
      upload_url: "#{upload_url}",
      flash_url: '/flash/swfupload/swfupload.swf',

      //example below lets you scope to only allowing image uploads
      //file_types: "*.jpg;*.jpeg;*.gif;*.png;",
      file_types: "*",
      file_types_description: "pictures",
      file_size_limit: "20 MB",

      button_placeholder_id: "spanButtonPlaceholder",
      button_width: 380,
      button_height: 32,
      button_text : '<span class="button">Select Files <span class="buttonSmall">(10 MB Max)</span></span>',
      button_text_style : '.button { font-family: Helvetica, Arial, sans-serif; font-size: 24pt; } .buttonSmall { font-size: 18pt; }',
      button_text_top_padding: 0,
      button_text_left_padding: 18,
      button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
      button_cursor: SWFUpload.CURSOR.HAND,
      file_queue_error_handler : fileQueueError,
      file_dialog_complete_handler : fileDialogComplete,
      upload_progress_handler : uploadProgress,
      upload_error_handler : uploadError,
      upload_success_handler : uploadSuccess,
      upload_complete_handler : uploadComplete,

      custom_settings : {
        upload_target: "divFileProgressContainer"
      }
    }
    var swf_upload = new SWFUpload(swf_settings);
  };
}

append_file 'config/initializers/session_store.rb', <<-FILE
require 'rack/utils'
 
class FlashSessionCookieMiddleware
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end
     
  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      params = ::Rack::Request.new(env).params
      env['HTTP_COOKIE'] = [ @session_key, params[@session_key] ].join('=').freeze unless params[@session_key].nil?
    end
    @app.call(env)
  end
end

ActionController::Dispatcher.middleware.insert_before(ActionController::Base.session_store, FlashSessionCookieMiddleware, ActionController::Base.session_options[:key])
FILE

# example Song resource for those who want it
controller_file = <<-FILE
class SongsController < ApplicationController
  layout 'swfupload'

  def index
    @songs = Song.all
  end

  def create
    require 'mime/types'
    mp3_info = Mp3Info.new(params[:Filedata].path)

    song = Song.new
    song.artist = mp3_info.tag.artist
    song.title = mp3_info.tag.title
    song.length_in_seconds = mp3_info.length.to_i

    params[:Filedata].content_type = MIME::Types.type_for(params[:Filedata].original_filename).to_s
    song.track = params[:Filedata]
    song.save

    render :text => [song.artist, song.title, song.convert_seconds_to_time].join(" - ")
  rescue Mp3InfoError => e
    render :text => "File error"
  rescue Exception => e
    render :text => e.message
  end
end
FILE


model_file = <<-FILE
class Song < ActiveRecord::Base
 
  has_attached_file :track
 
#  validates_presence_of :title, :artist, :length_in_seconds
  validates_attachment_presence :track
  validates_attachment_content_type :track, :content_type => [ 'application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3' ]
  validates_attachment_size :track, :less_than => 20.megabytes
 
  attr_accessible :title, :artist, :length_in_seconds

  def convert_seconds_to_time
    total_minutes = length_in_seconds / 1.minutes
    seconds_in_last_minute = length_in_seconds - total_minutes.minutes.seconds
    "\#{total_minutes}m \#{seconds_in_last_minute}s"
  end

 
end
FILE

view_file = <<-FILE
%h1 Songs

- @songs.each do |song|
  %p= song.title

= render 'swfupload/upload'
FILE

migration_file = <<-FILE
class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string :artist
      t.string :title
      t.integer :length_in_seconds
      t.string :track_file_name
      t.string :track_content_type
      t.integer :track_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end
FILE

layout_file = <<-FILE
!!! Strict
%html
  %head
    %title
      = h(yield(:title) || "Untitled")
    = '<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery.min.js"></script>'
    = '<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery-ui.min.js"></script>'
    = yield(:head)
  %body
    #container
      = yield
FILE

puts '=' * 80
if yes? "Create an example resource using Paperclip? (y/n)"
  FileUtils.mkdir_p 'app/views/songs'
  FileUtils.mkdir_p 'public/stylesheets/compiled'

  file 'app/views/layouts/swfupload.html.haml', layout_file
  file 'app/controllers/songs_controller.rb', controller_file
  file 'app/models/song.rb', model_file
  file 'app/views/songs/index.html.haml', view_file

  generate "migration", "create_songs"
  filename = Dir['db/migrate/*create_songs.rb'].first
  file filename, migration_file
  rake "db:migrate"

  gem 'paperclip'
  gem 'haml'
  gem 'ruby-mp3info', :lib => 'mp3info'

  run "sass app/stylesheets/swfupload.sass > public/stylesheets/compiled/swfupload.css"

  route 'map.resources :songs'

  puts "Now fire up the app and go to /songs to test it out!"
else
  puts "\nYour controller should have a create action that looks something like this:\n#{controller_file}"
  puts "\nYou can create a model that looks like this:\n#{model_file}"
end
