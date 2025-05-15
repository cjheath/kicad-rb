# ruby -w
#
# Pretty-printer for JLC libraries
#
require 'kicad'

k = KiCad.load(ARGV[0]).value

File.open('rewrite.kicad_sym', 'w') { |f| f.puts k.emit }
