module KiCad
  module AST
    class Node
      def initialize values, children
        @values = values
        @children = children
      end

      def emit depth = 0
        "\t"*depth +
        '(' +
        @values.map{|v| value(v) }*' ' +
        (@children.size == 0 ? '' : "\n" + @children.map{|c| c.emit(depth+1) }*''+"\t"*depth) +
        ")\n"
      end

      def value(v)
        case v
        when ::Symbol
          v.to_s
        when ::String
          v.inspect
        when ::Float, ::Integer
          v.to_s
        else
          "Internal error"
        end
      end
    end

    class KicadSymbolLib < Node
      def initialize values, children
        super
      end
    end

    # Uncomment or add whatever class you need to customise:
=begin
    class At < Node
    end

    class Center < Node
    end

    class Circle < Node
    end

    class Effects < Node
    end

    class EmbeddedFonts < Node
    end

    class End < Node
    end

    class ExcludeFromSim < Node
    end

    class Fill < Node
    end

    class Font < Node
    end

    class Generator < Node
    end

    class GeneratorVersion < Node
    end

    class Hide < Node
    end

    class InBom < Node
    end

    class Length < Node
    end

    class Name < Node
    end

    class Number < Node
    end

    class Offset < Node
    end

    class OnBoard < Node
    end

    class Pin < Node
    end

    class PinNames < Node
    end

    class PinNumbers < Node
    end

    class Polyline < Node
    end

    class Property < Node
    end

    class Pts < Node
    end

    class Radius < Node
    end

    class Rectangle < Node
    end

    class Size < Node
    end

    class Start < Node
    end

    class Stroke < Node
    end

    class Symbol < Node
    end

    class Type < Node
    end

    class Version < Node
    end

    class Width < Node
    end

    class Xy < Node
    end
=end

  end
end
