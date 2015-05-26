# CarrierWave::NoBrainer

This is a [NoBrainer](https://github.com/nviennot/nobrainer) adapter for CarrierWave gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carrierwave-nobrainer'
```

And then execute:

    $ bundle

## Usage

In your model put `include CarrierWave::NoBrainer` and then follow normal CarrierWave
procedure. For example:

```ruby
class User
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps
  include CarrierWave::NoBrainer

  field :name, type: String, required: true
  field :avatar, type: String
  mount_uploader :avatar, AvatarUploader
end
```

## Contributing

1. Fork it ( https://github.com/katafrakt/carrierwave-nobrainer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
