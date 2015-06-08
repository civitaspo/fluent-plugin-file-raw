# fluent-plugin-file-raw
[![Build Status](https://secure.travis-ci.org/civitaspo/fluent-plugin-file-raw.png?branch=master)](http://travis-ci.org/civitaspo/fluent-plugin-file-raw)

Fluentd plugin to output raw data to files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-file-raw'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-file-raw

## Configuration

example:

```
<match foo.**>
  type file_raw
  output_path /tmp/out
  output_file_prefix outfile
  output_delimiter TAB
</match>
```

output:

/tmp/out/outfile.%Y-%m-%d-%H.xxxxxxxxxxx

- %Y-%m-%d-%H: executed time
- xxxxxxxxxxx: 32 randam letters

#### parameter detail

|param|validation|explanation|
|:--|:--|:--|
|output_path|string|require the existence of the path.|
|output_file_prefix|string||
|bulk_tag_prefix|string|if the option is enabled, the output_delimiter option is disabled.|
|output_delimiter|'',TAB,COMMA|the delimiters except left ones are not permitted.|

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fluent-plugin-file-raw/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
