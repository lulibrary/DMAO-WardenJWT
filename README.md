# DMAO-WardenJWT

Warden Strategy for DMA Online JWT Authentication. Checks for a JWT (JSON Web Token) in either the Authorization header as a Bearer token or the get parameters of the request.

On successful authentication it returns an instance of DMAO::WardenJWT::User which has attributes and methods for checking the users institution as well as authenticated roles.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'DMAO-WardenJWT'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install Bundle-WardenJWT

## Usage

DMAO-WardenJWT requires the following environment variables to be set, this can be done using the [dotenv gem](https://rubygems.org/gems/dotenv).

| Environment Variable | Description |
| --- | --- |
| JWT_VERIFY_ISS | Boolean for whether to verify the token issuer (false allows for jwt_issuer to be nil) |
| JWT_VERIFY_AUD | Boolean for whether to verify the token audience (false allows for jwt_audience to be nil) |
| JWT_VERIFY_IAT | Boolean for whether to verify the issued at timestamp of the token |
| JWT_SECRET | The secret used to verify the integrity of the JWT (required) |
| JWT_ISSUER | The issuer of the JWT (required) |
| JWT_AUDIENCE | The audience for the JWT (required) |
| JWT_CUSTOM_CLAIMS_ATTRIBUTE | The name of the claim within the JWT to extract as the DMA Online custom claims (`dmao` is a sensible default) |

### Failure App

**DMAO-WardenJWT** does not define a failure app. Handling authentication failure should be handled within the service/application using this.

### Rails Usage

After including the gem add the following to `config/application.rb`. This is correct for using with Rails 5 when in API mode.

```ruby
config.middleware.insert_after Rack::ETag, Warden::Manager do |manager|
  manager.default_strategies :jwt
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lulibrary/DMAO-WardenJWT.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
