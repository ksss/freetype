require 'freetype/api'

module FreeTypeApiTest
  include FreeType::API

  def font_open
    ['data/Prida01.otf', 'data/Starjedi.ttf'].each do |font|
      Font.open(font) do |f|
        yield f, font
      end
    end
  end

  def test_library_version(t)
    v = FreeType::API.library_version
    unless String === v
      t.error 'return value was break'
    end
    unless /\A\d+.\d+.\d+\z/ =~ v
      t.error "version format was break got #{v}"
    end
  end

  def test_Font(t)
    font = nil
    ret = Font.open('data/Prida01.otf') do |f|
      font = f

      :abc
    end
    if font.nil?
      t.error('cannot get FT_Library in `open` with block')
    end
    if ret != :abc
      t.error 'want to return last value in block'
    end

    font_open do |f, _font|
      if f.char_index('a') == 0
        t.error('ascii char not defined this font')
      end
      if f.char_index('㍿') != 0
        t.error("I don't know why set character was defined in font")
      end

      v = f.kerning('A', 'W')
      unless v
        t.error('#kerning return object was changed')
      end
      unless Fixnum === v.x && Fixnum === v.y
        t.error('Not vector object. Check spec for FT_Get_Kerning()')
      end

      f.set_char_size(0, 0, 300, 300)

      bbox = f.bbox
      unless BBox === bbox
        t.error('FreeType::API::Face#bbox return value was break')
      end

      unless 0 < f.line_height
        t.error('Not expected behavior')
      end

      unless Glyph === f.glyph('a')
        t.error 'return value was break'
      end

      unless 0 < f.line_height
        t.error('Not expected behavior')
      end

      unless Glyph === f.notdef
        t.error 'return value was break'
      end
    end
  end

  def test_glyph(t)
    font_open do |f|
      f.set_char_size(0, 0, 300, 300)
      table = { 'a' => nil, 'b' => nil, 'c' => nil, 'd' => nil }
      table.each do |char, _|
        glyph = f.glyph(char)

        metrics = glyph.metrics
        unless FreeType::C::FT_Glyph_Metrics === metrics
          t.error 'return value was break'
        end

        char_width = glyph.char_width
        unless Fixnum === char_width
          t.error 'return value was break'
        end

        outline = glyph.outline
        unless Outline === outline
          t.error('FreeType::API::Face#outline return value was break')
        end

        ret = glyph.bold
        unless ret.nil?
          t.error SystemCallError.new(FFI.errno).message
        end

        ret = glyph.italic
        unless ret.nil?
          t.error SystemCallError.new(FFI.errno).message
        end
      end
    end
  end

  def test_outline(t)
    font_open do |f|
      f.set_char_size(0, 0, 300, 300)
      table = { 'a' => nil, 'b' => nil, 'c' => nil, 'd' => nil }
      table.each do |char, _|
        outline = f.glyph(char).outline

        unless 0 < outline.points.length
          t.error('FT_Outline.points get failed from ffi')
        end

        unless outline.points.all? { |i| Point === i }
          t.error('Miss array of FreeType::API::Outline#points objects assignment')
        end

        unless outline.tags.all? { |i| Fixnum === i }
          t.error('Got values miss assigned from ffi')
        end

        unless outline.contours.all? { |i| Fixnum === i }
          t.error('Got values miss assigned from ffi')
        end

        table[char] = outline.points.map(&:x)
      end
      if table.values.uniq.length != table.length
        t.error 'char reference miss'
      end
    end
  end
end
