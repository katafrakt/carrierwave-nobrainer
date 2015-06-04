# CarrierWave::NoBrainer

This is a [NoBrainer](https://github.com/nviennot/nobrainer) adapter for CarrierWave gem.

**Please note:** This version targets CarrierWave's master branch, which is under development. Expect bugs! (But also some nice features, like arrays of files). 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'
gem 'carrierwave-nobrainer', github: 'katafrakt/carrierwave-nobrainer'
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

Unlike ActiveRecord version, CarrierWave's methods are not included automatically to every NoBrainer model. This is because I believe that explicit is better than implicit. If you are not with me, you can add this to your initializer:

```ruby
NoBrainer::Document.send(:include, CarrierWave::NoBrainer)
```

## Contributing

1. Fork it ( https://github.com/katafrakt/carrierwave-nobrainer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
