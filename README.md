# KiCad

Parse, load, modify and rewrite Kicad (s-expression) files into a convenient tree structure for scripting

## Installation

    gem install kicad

## Usage Example

For all parts with no PartNumber property, copy it from the Value field and make sure it's hidden:

    $ irb -r kicad
    irb(main):001> k = KiCad.load('mylib.kicad_sym').value
    => 
    #<KiCad::AST::KicadSymbolLib:0x00000001473f5488
    ...
    irb(main):002> k.all_symbol.each{|s| s['PartNumber'] = s.property('Value') unless s.property('PartNumber') }; nil
    => nil
    irb(main):003> k.all_symbol.each{|s| s.property_node('PartNumber')&.hidden = true }
    => nil
    irb(main):001> File.open("rewrite.kicad_sym", "w") { |f| f.puts k.emit }
    ...

## Development

After checking out the repo, run `bundle` to install dependencies.

To install this gem onto your local machine from local source code, run `rake install`.

## Resources

KiCad uses a version of the Cadence SPECCTRA Design Language, defined in https://cdn.hackaday.io/files/1666717130852064/specctra.pdf

KiCad's documentation of this is at https://dev-docs.kicad.org/en/file-formats/sexpr-intro/
The documentation is incomplete. This library contains some items as found in KiCad 9 symbol libraries,
and doesn't contain everything documented above, especially of those have not been found.
Best efforts - if you find a problem, you discovered why this is open source.
lib/kicad/asts.rb is your starting point for adding metedata.

A related Rust library that was not consulted while building this is https://github.com/adom-inc/kicad_lib/tree/main/kicad_sexpr

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cjheath/kicad-rb

## License

The gem is open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

