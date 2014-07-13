require 'imgur/version'
require 'httparty'
require 'net/http'

module Imgur

  HTML_PATH = 'https://imgur.com/'
  API_PATH = 'https://api.imgur.com/3/'
  UPLOAD_PATH = 'upload'
  IMAGE_PATH = 'image/'
  ALBUM_GET_PATH = 'album/'
  ALBUM_CREATE_PATH = 'album'
  ACCOUNT_PATH = 'account/'

  class Client
    attr_accessor :client_id

    def initialize(client_id)
      @client_id = client_id
    end

    def post(url, body={})
      resp = HTTParty.post(url, body: body, headers: auth_header)
      raise NotFoundException.new if resp.response.is_a? Net::HTTPNotFound
      resp
    end

    def get(url, query={})
      resp = HTTParty.get(url, query: query, headers: auth_header)
      raise NotFoundException.new if resp.response.is_a? Net::HTTPNotFound
      resp
    end

    def get_image(id)
      url = API_PATH + IMAGE_PATH + id
      resp = get(url).parsed_response
      Image.new(resp['data'])
    end

    def get_album(id)
      url = API_PATH + ALBUM_GET_PATH + id
      resp = get(url).parsed_response
      Album.new resp['data']
    end

    def get_account(username)
      url = API_PATH + ACCOUNT_PATH + username
      resp = get(url).parsed_response
      # The Imgur API doesn't send the username back
      Account.new resp['data'], username
    end

    def update_album(album)
      album.update self
    end

    def me
      get_account 'me'
    end

    def upload(local_file)
      local_file.file.rewind
      image = local_file.file.read
      body = {image: image, type: 'file'}
      body[:title] = local_file.title if local_file.title
      body[:description] = local_file.description if local_file.description
      body[:album] = local_file.album_id if local_file.album_id
      resp = post(API_PATH + UPLOAD_PATH, body).parsed_response
      # the Imgur API doesn't send title or description back apparently.
      data = resp['data'].merge({'title' => body[:title], 'description' => body[:description]})
      Image.new(data)
    end

    def new_album(images=nil, options={})
      image_ids = []
      if images.is_a? Array
        if images[0].is_a? Image
          images.each do |img|
            image_ids << img.id
          end
        elsif images[0].is_a? String
          image_ids = images
        end
      elsif
        if images.is_a? Image
          image_ids << images.id
        elsif images.is_a? String
          image_ids << images
        end
      end
      options[:cover] = options[:cover].id if options[:cover].is_a? Image
      body = {ids: image_ids}.merge options
      url = API_PATH + ALBUM_CREATE_PATH
      resp = post(url, body).parsed_response
      id = resp['data']['id']
      album = get_album id
      album.deletehash = resp['data']['deletehash']
      album
    end

    def auth_header
      {'Authorization' => 'Client-ID ' + @client_id}
    end

  end

  class Account
    attr_accessor :id, :url, :bio, :reputation, :created, :pro_expiration,
                  :username
    def initialize(data, username=nil)
      @id = data['id']
      @url = data['url']
      @bio = data['bio']
      @reputation = data['reputation']
      @created = Time.at data['created']
      if data['pro_expiration'].is_a? Integer
        @pro = Time.at
      end
      @username = username
    end

  end

  class Comment
    attr_accessor :id, :image_id, :caption, :author, :author_id, :on_album, :ups,
                  :downs, :points, :date, :parent_id, :deleted, :children

    def initialize(data)
      @id = data['id']
      @image_id = data['image_id']
      @caption = data['caption']
      @author = data['author']
      @author_id = data['author_id']
      @on_album = data['on_album']
      @ups = data['ups']
      @downs = data['downs']
      @points = data['points']
      @date = Time.at data['datetime']
      @parent_id = data['parent_id']
      @deleted = deleted
    end

    def on_album?
      @on_album
    end

    def upvotes
      @ups
    end

    def downvotes
      @downs
    end

    def has_parent?
      @parent_id != nil
    end

    def deleted?
      @deleted
    end
  end

  class Album
    attr_accessor :id, :title, :description, :date, :cover, :cover_width,
                  :cover_height, :account_url, :privacy, :layout, :views,
                  :link, :deletehash, :images_count, :images

    def initialize(data)
      @id = data['id']
      @title = data['title']
      @description = data['description']
      @date = Time.at data['datetime']
      @cover = data['cover']
      @cover_width = data['cover_width']
      @account_url = data['account_url']
      @privacy = data['privacy']
      @layout = data['layout']
      @views = data['views']
      @link = data['link']
      @deletehash = data['deletehash']
      @images_count = data['images_count']
      @images = []
      data['images'].each do |img|
        @images << Image.new(img)
      end
    end

    def update(client)
      if @deletehash == nil
        raise UpdateException.new 'Album must have a deletehash to update'
      end
      url = API_PATH + ALBUM_GET_PATH + @deletehash
      image_ids = []
      # Make sure we're only strings
      @images.each do |img|
        if img.is_a? Image
          image_ids << img.id
        elsif img.is_a? String
          image_ids << img
        end
      end
      body = {
          ids: @images,
          title: @title,
          description: @description,
          privacy: @privacy,
          layout: @layout,
          cover: @cover
      }
      puts body
      client.post(url, body: body)
    end

  end

  # Represents an image stored on the computer
  class LocalImage
    attr_accessor :file, :title, :description, :album_id

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
    attr_accessor :id, :title, :description, :date, :type, :animated, :width,
                  :height, :size, :views, :bandwidth, :favorite, :nsfw, :section,
                  :deletehash, :link, :html_link

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
      @html_link = HTML_PATH + @id
    end

  end

  class NotFoundException < Exception
    def initialize(msg='404 Not Found')
      super msg
    end
  end

  class UpdateException < Exception
    def initialize(msg)
      super msg
    end
  end

  def self.new(client_id)
    Client.new client_id
  end

end
