# KiCad

Parse, load, modify and rewrite Kicad (s-epression) files into a convenient tree structure for scripting

## Installation

    ```ruby
    gem 'kicad'
    ```

or

    gem install kicad

## Usage

    $ irb -r kicad
    irb(main):001> KiCad.load("my_file.kicad_lib").value
    ...

## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine from local source code, run `rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cjheath/kicad-rb

## License

The gem is open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

