# KiCad

Parse, load, modify and rewrite Kicad (s-epression) files into a convenient tree structure for scripting

## Installation

    gem install kicad

## Usage

    $ irb -r kicad
    irb(main):001> k = KiCad.load("my_file.kicad_sym").value
    irb(main):001> k.children.filter{|c| KiCad::AST::Symbol === c }.map{|c| c.values[1]}
    ["BC107", "CD4046"]
    irb(main):001> puts k.emit
    ...

## Development

After checking out the repo, run `bundle` to install dependencies.

To install this gem onto your local machine from local source code, run `rake install`.

## Resources

KiCad uses a version of the Cadence SPECCTRA Design Language, defined in https://cdn.hackaday.io/files/1666717130852064/specctra.pdf

KiCad's documentation of this is at https://dev-docs.kicad.org/en/file-formats/sexpr-intro/

A related Rust library that was not consulted while building this is https://github.com/adom-inc/kicad_lib/tree/main/kicad_sexpr

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cjheath/kicad-rb

## License

The gem is open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

