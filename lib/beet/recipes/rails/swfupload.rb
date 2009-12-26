base_url = 'http://code.google.com/p/swfupload/source/browse/swfupload/trunk/core/plugins'

js_files = %w(swfupload.cookies swfupload.queue swfupload.speed swfupload.swfobject)

run 'mkdir public/javascripts/swfupload'
run 'mkdir public/flash'
run 'mkdir app/views/swfupload'


js_files.each do |js_file|
  run "curl -L #{base_url}/#{js_file}.js > public/javascripts/swfupload/#{js_file}.js"
end

run "curl -L http://code.google.com/p/swfupload/source/browse/swfupload/trunk/core/Flash/swfupload.swf > public/javascripts/public/flash/swfupload.swf"


file 'app/views/swfupload/_upload.html.haml', <<-FILE
- content_for :head do
  = javascript_include_tag 'swfupload/swfupload', 'swfupload/swfupload.swfobject', 'swfupload/handlers'
  = stylesheet_link_tag %w(compiled/swfupload)
- session_key_name = ActionController::Base.session_options[:key]

- upload_url = swf_upload_account_admin_site_gallery_photo_album_photos_path(@account, @photo_album) 
- form_tag upload_url, :multipart => true do
  #swfupload_degraded_container
    %noscript= "You should have Javascript enabled for a nicer upload experience"
    = file_field_tag :Filedata
    = submit_tag "Add a File"
  #swfupload_container{ :style => "display: none" }
    %span#spanButtonPlaceholder
  #divFileProgressContainer
FILE

create_action = <<-FILE
require 'mp3info'
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
FILE

model = <<-FILE
class Song < ActiveRecord::Base
 
  has_attached_file :track,
                    :path => ":rails_root/public/assets/:attachment/:id_partition/:id/:style/:basename.:extension",
                    :url => "/assets/:attachment/:id_partition/:id/:style/:basename.:extension"
 
  validates_presence_of :title, :artist, :length_in_seconds
  validates_attachment_presence :track
  validates_attachment_content_type :track, :content_type => [ 'application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3' ]
  validates_attachment_size :track, :less_than => 20.megabytes
 
  attr_accessible :title, :artist, :length_in_seconds
 
  def convert_seconds_to_time
    total_minutes = length_in_seconds / 1.minutes
    seconds_in_last_minute = length_in_seconds - total_minutes.minutes.seconds
    "#{total_minutes}m #{seconds_in_last_minute}s"
  end
end
FILE

javascript_config = <<-FILE
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

      file_types: "*.jpg;*.jpeg;*.gif;*.png;",
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
FILE


file 'config/initializers/session_store.rb', <<-FILE
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
