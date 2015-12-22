require 'freetype/c'
require 'freetype/error'

module FreeType
  # high level API for freetype wrapping by FFI
  module API
    def library_version
      library = ::FFI::MemoryPointer.new(:pointer)
      err = FreeType::C::FT_Init_FreeType(library)
      raise FreeType::Error.find(err) unless err == 0

      amajor = ::FFI::MemoryPointer.new(:int)
      aminor = ::FFI::MemoryPointer.new(:int)
      apatch = ::FFI::MemoryPointer.new(:int)
      FreeType::C::FT_Library_Version(library.get_pointer(0), amajor, aminor, apatch)
      "#{amajor.get_int(0)}.#{aminor.get_int(0)}.#{apatch.get_int(0)}"
    ensure
      err = FreeType::C::FT_Done_Library(library.get_pointer(0))
      raise FreeType::Error.find(err) unless err == 0
    end
    module_function :library_version

    module IOInterface
      def open(*args)
        i = new(*args)
        if block_given?
          begin
            yield i
          ensure
            i.close
          end
        else
          i
        end
      end
    end

    class Font
      extend IOInterface
      include C

      attr_reader :face
      def initialize(font_path)
        @library = ::FFI::MemoryPointer.new(:pointer)
        err = FT_Init_FreeType(@library)
        raise FreeType::Error.find(err) unless err == 0

        @font_path = font_path

        f = ::FFI::MemoryPointer.new(:pointer)
        err = FT_New_Face(@library.get_pointer(0), @font_path, 0, f)
        raise FreeType::Error.find(err) unless err == 0
        @face = FT_FaceRec.new(f.get_pointer(0))
      end

      def close
        err = FT_Done_Face(@face)
        raise FreeType::Error.find(err) unless err == 0

        err = FT_Done_Library(@library.get_pointer(0))
        raise FreeType::Error.find(err) unless err == 0
      end

      def select_charmap(enc_code)
        err = FT_Select_Charmap(@face, enc_code)
        raise FreeType::Error.find(err) unless err == 0
      end

      def set_char_size(char_width, char_height, horz_resolution, vert_resolution)
        err = FT_Set_Char_Size(@face, char_width, char_height, horz_resolution, vert_resolution)
        raise FreeType::Error.find(err) unless err == 0
      end

      # TODO: Should be use FT_Get_Glyph
      def notdef
        glyph("\x00".freeze)
      end

      # TODO
      # Should be use FT_Get_Glyph and FT_Done_Glyph
      # Because return value will be change after call FT_Load_Char
      def glyph(char)
        load_char(char)
        Glyph.new(@face[:glyph])
      end

      def char_index(char)
        FT_Get_Char_Index(@face, char.ord)
      end

      def line_height
        @face[:size][:metrics][:height]
      end

      def bbox
        bbox = @face[:bbox]
        BBox.new(bbox[:xMin], bbox[:xMax], bbox[:yMin], bbox[:yMax])
      end

      def kerning(before_char, after_char)
        get_kerning(before_char, after_char, :FT_KERNING_DEFAULT)
      end
      alias_method :kerning_default, :kerning

      def kerning_unfitted(before_char, after_char)
        get_kerning(before_char, after_char, :FT_KERNING_UNFITTED)
      end

      def kerning_unscaled(before_char, after_char)
        get_kerning(before_char, after_char, :FT_KERNING_UNSCALED)
      end

      private

      def get_kerning(before_char, after_char, kerning_mode)
        if before_char.nil? || before_char == ''.freeze || after_char.nil? || after_char == ''.freeze
          return Vector.new(0, 0)
        end

        v = FT_Vector.new
        err = FT_Get_Kerning(
          @face,
          char_index(before_char),
          char_index(after_char),
          kerning_mode,
          v,
        )
        raise FreeType::Error.find(err) unless err == 0

        Vector.new(v[:x], v[:y])
      end

      def load_char(char)
        err = FT_Load_Char(@face, char.ord, FreeType::C::FT_LOAD_DEFAULT)
        unless err == 0
          e = FreeType::Error.find(err)
          if FreeType::Error::Invalid_Size_Handle === e
            warn 'should be call FT_Set_Char_Size before FT_Load_Char'
          end
          raise e
        end
      end
    end

    class Glyph
      include C

      def initialize(glyph)
        @glyph = glyph
      end

      def [](key)
        @glyph[key]
      end

      def metrics
        @glyph[:metrics]
      end

      def outline
        Outline.new(@glyph[:outline])
      end

      def char_width
        @glyph[:metrics][:horiAdvance]
      end

      def bold
        FT_GlyphSlot_Embolden(@glyph)
      end

      def oblique
        FT_GlyphSlot_Oblique(@glyph)
      end
      alias_method :italic, :oblique
    end

    class Outline
      include C

      def initialize(outline)
        @outline = outline
      end

      def [](key)
        @outline[key]
      end

      def points
        points = @outline[:n_points].times.map do |i|
          FT_Vector.new(@outline[:points] + i * FT_Vector.size)
        end
        points.zip(tags).map do |(point, tag)|
          Point.new(tag, point[:x], point[:y])
        end
      end

      def contours
        return [] if @outline[:n_contours] == 0
        @outline[:contours].get_array_of_short(0, @outline[:n_contours])
      end

      def tags
        return [] if @outline[:n_points] == 0
        @outline[:tags].get_array_of_char(0, @outline[:n_points])
      end
    end

    Point = Struct.new(:tag, :x, :y) do
      def on_curve?
        tag & 0x01 != 0
      end
    end

    Vector = Struct.new(:x, :y)
    BBox = Struct.new(:x_min, :x_max, :y_min, :y_max)
  end
end
