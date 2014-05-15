require 'imgur/version'
require 'httparty'

module Imgur


  API_PATH = 'https://api.imgur.com/3/'
  UPLOAD_PATH = 'upload'

  class Client
    attr_accessor :client_id

    def initialize(client_id)
      @client_id = client_id
    end

    def post(url, body={})
      HTTParty.post(url, body: body, headers: auth_header)
    end

    def get(url, data={})
      HTTParty.get(url, query: data, headers: auth_header)
    end

    def upload(local_file)
      local_file.file.rewind
      image = local_file.file.read
      body = {image: image, type: 'file'}
      body[:title] = local_file.title if local_file.title
      body[:description] = local_file.description if local_file.description
      body[:album] = local_file.album_id if local_file.album_id
      resp = post(API_PATH + UPLOAD_PATH, body).parsed_response
      puts resp['data']
      Image.new(resp['data'])
    end

    def auth_header
      {'Authorization' => 'Client-ID ' + @client_id}
    end

  end

  # Represent an image stored on the computer
  class LocalImage
    attr_accessor :file
    attr_accessor :title
    attr_accessor :description
    attr_accessor :album_id

    def initialize(file, options={})
      if file.is_a? String
        @file = File.open file, 'rb'
      else
        @file = file
      end
      @title = options[:title]
      @description = options[:description]
      @album_id = options[:album_id]
    end

  end

  # Represents an image on Imgur
  class Image
    attr_accessor :id
    attr_accessor :title
    attr_accessor :description
    attr_accessor :date # Time object of :datetime
    attr_accessor :type
    attr_accessor :animated
    attr_accessor :width
    attr_accessor :height
    attr_accessor :size
    attr_accessor :views
    attr_accessor :bandwidth
    attr_accessor :favorite
    attr_accessor :nsfw
    attr_accessor :section
    attr_accessor :deletehash
    attr_accessor :link

    def initialize(data)
      @id = data['id']
      @title = data['title']
      @description = data['description']
      @date = Time.at data['datetime']
      @type = data['type']
      @animated = data['animated']
      @width = data['width']
      @height = data['height']
      @size = data['size']
      @views = data['views']
      @bandwidth = data['bandwidth']
      @favorite = data['favorite']
      @nsfw = data['nsfw']
      @section = data['section']
      @deletehash = data['deletehash']
      @link = data['link']
    end

  end

  def self.new(client_id)
    Client.new client_id
  end

end
