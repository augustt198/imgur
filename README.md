# Imgur

Ruby wrapper for the Imgur API.

## Installation

If you're using Bundler:

```ruby
gem 'imgur', github: 'augustt198/imgur'
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
