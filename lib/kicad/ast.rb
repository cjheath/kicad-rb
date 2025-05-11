module KiCad
  module AST
    class Node
      attr_reader :values, :children

      def initialize values, children
        @values = values
        @children = children
      end

      def emit depth = 0
        "\t"*depth +
        '(' +
        @values.map{|v| String === v ? v.inspect : v.to_s }*' ' +
        (@children.size == 0 ? '' : "\n" + @children.map{|c| c.emit(depth+1) }*''+"\t"*depth) +
        ")\n"
      end

      # A replacement for a Node#emit that wants descendents compacted
      def emit_compacting depth = 0
        "\t"*depth + emit_compact + "\n"
      end

      def emit_compact
        '(' +
        [ @values.map{|v| String === v ? v.inspect : v.to_s },
          @children.map{|c| c.emit_compact() }
        ].flatten*' ' +
        ')'
      end

      # Define setter and getter methods for each value type this class allows
      def self.value_types vts
        i = 1   # @values[0] is always the class symbol
        vts.each do |k, v|
          # puts "#{self.name} attribute #{k.to_s} => #{v.inspect}"
          # puts "attr_accessor #{self.name}.#{k} (values #{v.inspect}) is stored in @values[#{i}]"
          begin
            o = i # Avoid capturing i after the loop ends
            define_method(:"#{k}") do
              # puts "accessing #{self.class.name}.#{k} as @values[#{o}]"
              @values[o]
            end
            define_method(:"#{k}=") do |v|
              # puts "setting #{self.class.name}.#{k} as @values[#{o}]"
              # REVISIT: Check valid data type matching v
              @values[o] = v
            end
          end
          i = i+1
        end
      end

      def children_of_type *cts  # cts is an array of AST class symbols or strings
        class_names = cts.flatten.map{|k| 'KiCad::AST::'+self.class.to_class_name(k)}
        @children.filter{|h| class_names.include?(h.class.name) }
      end

      # Define methods for each child type this class allows
      def self.child_types *cts
        # puts "#{self.name} allows child types #{cts.inspect}"
        cts.each do |c|
          if Array === c
            define_method(:"all_#{c[0].to_s}") do
              # puts "Looking for all [#{class_names*', '}] in #{@children.map{|q| q.class.name}.inspect}"
              children_of_type(c)
            end
            # REVISIT: Allow deleting and adding instances to the array
            # new_child = KiCad.parse('(some new node)').value
            # @children.append(new_child)
          else
            class_name = 'KiCad::AST::'+to_class_name(c)
            define_method(:"#{c}") do
              # puts "Looking for first #{class_name} in #{@children.map{|q| q.class.name}.inspect}"
              a = children_of_type(c)
              puts "Choosing first #{self.class.name}.#{c} of #{a.size}" if a.size > 1
              a.first
            end
            # Allow deleting this instance
            define_method(:"unset_#{c.to_s}") do
              child = send(:"#{c}")
              @children = @children - [child] if child
              child ? true : nil
            end
          end
        end
      end

      def self.to_class_name sym
        sym.to_s.gsub(/\A[a-z]|_[a-z]/) {|from| from[-1].upcase }
      end

      def self.to_symbol class_name
        class_name.to_s.gsub(/[A-Z]/) {|from| '_'+from[-1].downcase }.sub(/\A_/,'')
      end
    end

    class KicadSymbolLib < Node
      child_types :version, :generator, :generator_version, [:symbol]
    end

    class Generator < Node
      def emit depth = 0
        emit_compacting depth
      end
    end

    class GeneratorVersion < Node
      def emit depth = 0
        emit_compacting depth
      end
    end

    class Version < Node
      def emit depth = 0
        emit_compacting depth
      end
    end

    # Uncomment or add whatever class you need to customise:

    # Position Identifier
    class At < Node
      value_types :x => Float, :y => Float, :angle => Float

      def emit depth = 0
        emit_compacting depth
      end
    end

    # Coordinate Point List
    class Pts < Node
      value_types({})
      child_types [:xy]
    end

    class Xy < Node
      value_types :x => Float, :y => Float
    end

    # Stroke Definition
    class Stroke < Node
      child_types :width, :type, :color

      def emit depth = 0
        emit_compacting depth
      end
    end

    class Width < Node
      value_types :width => Float
    end

    class Type < Node
      value_types :type => [:dash, :dash_dot, :dash_dot_dot, :dot, :default, :solid]
    end

    class Color < Node
      value_types :r => Integer, :g => Integer, :b => Integer, :a => Integer
    end

    # Text Effects
    class Effects < Node
      child_types :font, :justify, :hide

      def emit depth = 0
        if @children.size <= 1
          emit_compacting depth
        else
          super
        end
      end
    end

    class Font < Node
      child_types :face, :size, :thickness, :bold, :italic, :line_spacing

      def emit depth = 0
        if @children.size <= 1
          emit_compacting depth
        else
          super
        end
      end
    end

    class Face < Node
      value_types :face_name => String
    end

    class Size < Node
      value_types :height => Float, :width => Float
    end

    class Thickness < Node
      value_types :thickness => Float
    end

    class Bold < Node
      value_types :bold => [:no, :yes]
    end

    class Italic < Node
      value_types :bold => [:no, :yes]
    end

    class LineSpacing < Node
      value_types :line_spacing => Float
    end

    class Justify < Node
      value_types :justify => [[:right, :left, :top, :bottom, :mirror]]   # Can have multiple
    end

    class Hide < Node
      value_types :hide => [:no, :yes]
    end

    # Page Settings
    class Paper < Node
      # REVISIT: Either paper_size or width/height
      value_types :paper_size => [:A0, :A1, :A2, :A3, :A4, :A5, :A, :B, :C, :D, :E],
          :width => Float, :height => Float,
          :portrait => [:portrait]
    end

    # Title Block
    class TitleBlock < Node
      child_types :title, :date, :rev, :company,        # All take one string as value
          [:comment]                                    # N (1..9) and String # REVISIT: Implement Comment
    end

    # Properties
    class Property < Node
      value_types :key => String, :value => String
      child_types :at, :effects

      # Set or clear (hide) on the property_node
      def hidden=(h = true)
        v = (h ? :yes : :no)
        if !effects                     # No effects yet
          prop = KiCad.parse(%Q{(effects(hide #{v}))})&.value
          @children.append(prop) if prop
        elsif (existing = effects.hide) # Effects and hide already
          existing.hide = v
        else                            # Create new (hide) node
          prop = KiCad.parse(%Q{(hide #{v})})&.value
          @children.append(prop) if prop
        end
      end
    end

    # Universally Unique Identifier
    class Uuid < Node
      value_types :uuid => String
    end

    # Images
    class Image < Node
      child_types :at, :scale, :layer, :uuid, :data
    end

    class Data < Node
      value_types :data => String    # REVISIT: Base64 data - not encoded as a string I think?
    end

    class Circle < Node
      child_types :center, :radius, :stroke, :fill
    end

    class Center < Xy
      # value_types :x => Float, :y => Float
    end

    class Radius < Node
      value_types :radius => Float
    end

    class Fill < Node
      value_types :fill => [:no, :yes]
      child_types :type

      def emit depth = 0
        emit_compacting depth
      end
    end

    class Arc < Node
      child_types :start, :mid, :end, :stroke, :fill
    end

    class Start < Xy
      # value_types :x => Float, :y => Float
    end

    class Mid < Xy
      # value_types :x => Float, :y => Float
    end

    class End < Xy
      # value_types :x => Float, :y => Float
    end

    class Rectangle < Node
      child_types :start, :end, :stroke, :fill
    end

    class Polyline < Node
      child_types :pts, :stroke, :fill
    end

    class Text < Node
      value_types :text => String
      child_types :at, :effects
    end

    class Offset < Xy
      # value_types :x => Float, :y => Float
    end

    # Symbol Pins
    class Pin < Node
      value_types :electrical_type => [
            :input,                             # Pin is an input.
            :output,                            # Pin is an output.
            :bidirectional,                     # Pin can be both input and output.
            :tri_state,                         # Pin is a tri-state output.
            :passive,                           # Pin is electrically passive.
            :free,                              # Not internally connected.
            :unspecified,                       # Pin does not have a specified electrical type.
            :power_in,                          # Pin is a power input.
            :power_out,                         # Pin is a power output.
            :open_collector,                    # Pin is an open collector output.
            :open_emitter,                      # Pin is an open emitter output.
            :no_connect,                        # Pin has no electrical connection.
          ], :graphic_style => [
            :line,
            :inverted,
            :clock,
            :inverted_clock,
            :input_low,
            :clock_low,
            :output_low,
            :edge_clock_high,
            :non_logic
          ]
      child_types :length, :name, :number
    end

    class Length < Node
      value_types :length => Float
    end

    class Name < Node
      value_types :name => String
      child_types :effects
    end

    class Number < Node
      value_types :number => String
      child_types :effects
    end

    class Polygon < Node
      child_types :pts, :stroke, :fill
    end

    # Symbols
    class Symbol < Node
      value_types :id => String
      child_types :extends, :exclude_from_sym, :pin_numbers, :pin_names, :in_bom, :on_board,
        [:property],
        [:shape, :circle, :rectangle, :text, :polyline, :arc],  # REVISIT: Lots more types of graphic items here...
        [:pin],
        [:symbol],      # Child symbols (units) embedded in a parent
        :unit_name,
        :embedded_fonts

      # Get or set Property values by key, or as a Hash
      def property_node k
        self.all_property.detect{|p| p.key == k}
      end

      def property k = nil
        if k
          property_node(k)&.value
        else  # Return all properties as a Hash
          Hash[*self.all_property.map{|p| [p.key, p.value] }.flatten]
        end
      end

      def [](k)
        property[k]
      end

      def []=(k, v)
        # puts "Setting property #{k} to #{v.inspect}"
        if (prop = property_node(k))
          prop.value = v
        else  # Create new Property using the parser:
          prop = KiCad.parse(%Q{
            (property "#{k}" #{String === v ? v.inspect : v.to_s}
              (at 0 0 0)
              (effects(font(size 1.27 1.27)) (hide yes))
            )
          })&.value
          @children.append(prop) if prop
        end
        prop
      end
    end

    class Extends < Node
      value_types :library_id => String
    end

    class PinNumbers < Node
      # This is a child node, not as documented (a value in https://dev-docs.kicad.org/en/file-formats/sexpr-intro/)
      child_types :hide

      def emit depth = 0
        emit_compacting depth
      end
    end

    class PinNames < Node
      child_types :offset, :hide

      def emit depth = 0
        emit_compacting depth
      end
    end

    class InBom < Node
      value_types :in_bom => [:no, :yes]
    end

    class OnBoard < Node
      value_types :on_board => [:no, :yes]
    end

    class UnitName < Node
      value_types :name => String
    end

    class EmbeddedFonts < Node
      value_types :embedded_fonts => [:no, :yes]
    end

    class ExcludeFromSim < Node
      value_types :exclude_from_sim => [:no, :yes]
    end

  end
end
