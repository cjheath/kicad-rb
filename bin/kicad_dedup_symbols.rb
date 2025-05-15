# ruby -w
#
# Find duplicate symbol rendering in a Kicad library
# Merged symbols must have same appearance and reference designator
#
require 'kicad'
require 'debug'

k = KiCad.load(ARGV[0]).value

symbols_by_pretty = {}

k.all_symbol.
  each do |s|
    child_symbols = s.all_symbol

    # the key is the concatenated pretty-printed contents of all child symbols
    key =
      child_symbols.map do |c|
        s['Reference'].inspect+':' +
        c.children.filter{|e| KiCad::AST::Property === e}.map(&:emit).sort*" "
      end.sort*"\n"

    existing = symbols_by_pretty[key]
    if existing
      puts "#{s.id} is a dup of #{existing.id}"

      # delete all child symbols, prepend extends:
      s.children.delete_if{|c| child_symbols.include?(c)}
      s.children.prepend(KiCad.parse("(extends #{existing.id.inspect})")&.value)
    else
      symbols_by_pretty[key] = s
    end
  end

File.open('rewrite.kicad_sym', 'w') { |f| f.puts k.emit }
