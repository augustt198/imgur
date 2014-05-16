# Imgur

Ruby wrapper for the Imgur API.

## Installation

Install with RubyGems:

```ruby
gem install 'imgur-api'
```

Or add to your Gemfile:

```ruby
gem 'imgur-api'
```


## Usage

For anonymous usage, create a new client with your Client-ID

```ruby
client = Imgur.new(client_id) # or Imgur::Client.new(client_id)
```

To upload an image, first create a `Imgur::LocalImage`
```ruby
image = Imgur::LocalImage.new('path/to/image', title: 'Awesome photo')
```

Then use the client to upload it and recieve a `Imgur::Image`
```ruby
uploaded = client.upload(image)
# uploaded.link => http://i.imgur.com/...
```

Creating an album is super easy!
```ruby
# The first argument can also be an array of images, or nil for a blank album.
album = client.new_album(uploaded, title: 'My Photography')

# album.link => http://imgur.com/a/...
```
