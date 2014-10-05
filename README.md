# Apolo

A lightweight framework based on a hexagonal architecture for building automation, monitoring, and metrics plugins in ruby. 

The goals of the framework:
1. Ruby is an object-oriented language with great support for functional programming, and I want to make the most of that to keep apolo's code easy to change.
2. Clean and well-organised
I want a structure that communicates what each part of the system is doing.
3. DRY - The focus is on the domain classes so I can re-use them for Chef, Nagios, collectd, and what ever else I come across. 
[![Gem Version](https://badge.fury.io/rb/apolo.svg)](http://badge.fury.io/rb/apolo)
[![Build Status](http://img.shields.io/SteelHouseLabs/apolo/apolo.svg)][travis]
[![Dependency Status](http://img.shields.io/gemnasium/SteelHouseLabs/apolo.svg)][gemnasium]
[![Code Climate](http://img.shields.io/codeclimate/github/SteelHouseLabs/apolo.svg)][codeclimate]

[gem]: https://rubygems.org/gems/apolo
[travis]: http://travis-ci.org/SteelHouseLabs/apolo
[gemnasium]: https://gemnasium.com/SteelHouseLabs/apolo
[codeclimate]: https://codeclimate.com/github/SteelHouseLabs/apolo

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'apolo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apolo

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/apolo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
