require 'treetop'
require_relative 'grammar'

module KiCad
  def self.parse string
    p = Parser.new
    result = p.parse string
    if !result
      throw "KiCad::SExpr parse failed at line #{p.failure_line} column #{p.failure_column}: #{p.failure_reason}"
    end
    result
  end

  def self.load filename
    self.parse File.read(filename, :encoding => 'iso-8859-1')
  end

  class Parser < KiCad::SExprParser
  end
end
