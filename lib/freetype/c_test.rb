require 'freetype/c'

module FFITest
  include FreeType::C

  FONTS = ['data/Prida01.otf', 'data/Starjedi.ttf']

  def libopen
    library = ::FFI::MemoryPointer.new(:pointer)
    err = FT_Init_FreeType(library)
    raise FreeType::Error.find(err) unless err == 0

    FONTS.each do |font|
      face = ::FFI::MemoryPointer.new(:pointer)
      begin
        err = FT_New_Face(library.get_pointer(0), font, 0, face)
        raise FreeType::Error.find(err) unless err == 0

        yield FT_FaceRec.new(face.get_pointer(0)), font
      ensure
        err = FT_Done_Face(face.get_pointer(0))
        raise FreeType::Error.find(err) unless err == 0
      end
    end
  ensure
    err = FT_Done_Library(library.get_pointer(0))
    raise FreeType::Error.find(err) unless err == 0
  end

  def test_Library(t)
    library = ::FFI::MemoryPointer.new(:pointer)
    err = FT_Init_FreeType(library)
    if err != 0
      t.fatal FreeType::Error.find(err).message
    end

    amajor = FFI::MemoryPointer.new(:int)
    aminor = FFI::MemoryPointer.new(:int)
    apatch = FFI::MemoryPointer.new(:int)
    FT_Library_Version(library.get_pointer(0), amajor, aminor, apatch)
    a = [
      amajor.get_int(0),
      aminor.get_int(0),
      apatch.get_int(0),
    ]
    unless a.all? { |i| Fixnum === i }
      t.error 'miss get values from FT_Library_Version()'
    end
    t.log "freetype version: #{a.join('.')}"
  ensure
    err = FT_Done_Library(library.get_pointer(0))
    if err != 0
      t.error FreeType::Error.find(err).message
    end
  end

  def test_Face(t)
    library = ::FFI::MemoryPointer.new(:pointer)
    err = FT_Init_FreeType(library)
    if err != 0
      t.fatal FreeType::Error.find(err).message
    end
    FONTS.each do |font|
      face = ::FFI::MemoryPointer.new(:pointer)
      err = FT_New_Face(library.get_pointer(0), font, 0, face)
      if err != 0
        t.fatal FreeType::Error.find(err).message
      end

      begin
        face = FT_FaceRec.new(face.get_pointer(0))
        err = FT_Select_Charmap(face, :FT_ENCODING_UNICODE)
        if err != 0
          t.error FreeType::Error.find(err).message
        end
      ensure
        err = FT_Done_Face(face)
        if err != 0
          t.error FreeType::Error.find(err).message
        end
      end
    end
  ensure
    err = FT_Done_Library(library.get_pointer(0))
    if err != 0
      t.error FreeType::Error.find(err).message
    end
  end

  def test_FT_Set_Char_Size(t)
    libopen do |face|
      err = FT_Set_Char_Size(face, 0, 32, 300, 300)
      if err != 0
        t.error FreeType::Error.find(err).message
      end

      err = FT_Load_Char(face, 'a'.ord, FreeType::C::FT_LOAD_DEFAULT)
      if err != 0
        t.error FreeType::Error.find(err).message
      end
    end
  end

  def test_FT_Get_Glyph_Name(t)
    libopen do |face|
      buff = FFI::MemoryPointer.new(:pointer)
      err = FT_Get_Glyph_Name(face, 0, buff, 32)
      if err != 0
        t.error FreeType::Error.find(err).message
      end
      unless String === buff.get_string(0)
        t.error 'May buffering miss?'
      end
    end
  end

  def test_FT_Outline_Decompose(t)
    libopen do |face|
      t.error('err') if FT_Set_Char_Size(face, 0, 32, 300, 300) != 0
      t.error('err') if FT_Load_Char(face, 'a'.ord, FreeType::C::FT_LOAD_DEFAULT) != 0

      vectors = []
      outline_funcs = FT_Outline_Funcs.new
      outline_funcs[:move_to] = Proc.new { |to|
        vectors << ['M', to[:x], to[:y]]
        0
      }
      outline_funcs[:line_to] = Proc.new { |to|
        vectors << ['L', to[:x], to[:y]]
        0
      }
      outline_funcs[:conic_to] = Proc.new { |ctrl, to|
        vectors << ['Q', ctrl[:x], ctrl[:y], to[:x], to[:y]]
        0
      }
      outline_funcs[:cubic_to] = Proc.new { |ctrl1, ctrl2, to|
        vectors << ['C', ctrl1[:x], ctrl1[:y], ctrl2[:x], ctrl2[:y], to[:x], to[:y]]
        0
      }
      err = FT_Outline_Decompose(face[:glyph][:outline], outline_funcs, nil)
      if err != 0
        t.error FreeType::Error.find(err).message
      end
      if vectors.empty?
        t.error "callbacks was not called"
      end
    end
  end

  def test_FT_Outline_Embolden(t)
    libopen do |face|
      t.error('err') if FT_Set_Char_Size(face, 0, 32, 300, 300) != 0
      t.error('err') if FT_Load_Char(face, 'a'.ord, FreeType::C::FT_LOAD_DEFAULT) != 0
      if face[:glyph][:format] != :FT_GLYPH_FORMAT_OUTLINE
        t.error "cannot call FT_Outline_Embolden() to format: `#{face[:glyph][:format]}'"
      end
      err = FT_Outline_Embolden(face[:glyph][:outline], 1 << 6)
      if err != 0
        t.error FreeType::Error.find(err).message
      end
    end
  end

  def test_FT_Outline_Transform(t)
    libopen do |face|
      t.error('err') if FT_Set_Char_Size(face, 0, 32, 300, 300) != 0
      t.error('err') if FT_Load_Char(face, 'a'.ord, FreeType::C::FT_LOAD_DEFAULT) != 0
      if face[:glyph][:format] != :FT_GLYPH_FORMAT_OUTLINE
        t.error "cannot call FT_Outline_Embolden() to format: `#{face[:glyph][:format]}'"
      end
      m = FT_Matrix.new
      m[:xx] = 1 << 16
      m[:xy] = 0x5800
      m[:yx] = 0
      m[:yy] = 1 << 16
      ret = FT_Outline_Transform(face[:glyph][:outline], m)
      unless ret.nil?
        t.error SystemCallError.new(FFI.errno).message
      end
    end
  end

  def test_FT_Outline_Reverse(t)
    libopen do |face|
      t.error('err') if FT_Set_Char_Size(face, 0, 32, 300, 300) != 0
      t.error('err') if FT_Load_Char(face, 'a'.ord, FreeType::C::FT_LOAD_DEFAULT) != 0
      unless FT_Outline_Reverse(face[:glyph][:outline]).nil?
        t.error 'return value was break'
      end
    end
  end

  def test_char(t)
    libopen do |face, _font|
      err = FT_Set_Char_Size(face, 0, 32, 300, 300)
      if err != 0
        t.fatal FreeType::Error.find(err).message
      end

      before_glyph_id = nil
      %w(i e f g A W & * @ % - + < >).concat([' ', 'あ', '　', "\n"]).each do |char|
        glyph_id = FT_Get_Char_Index(face, char.ord)
        if glyph_id == 0
          unless /あ|　|\n/.match(char)
            t.error('ascii char is undefined')
          end
          next
        end

        if before_glyph_id
          v = FT_Vector.new
          err = FT_Get_Kerning(face, before_glyph_id, glyph_id, :FT_KERNING_UNFITTED, v)
          if err != 0
            t.error FreeType::Error.find(err).message
          end
          unless Fixnum === v[:x] && Fixnum === v[:y]
            t.error 'cannot get kerning value from FT_Get_Kerning()'
          end
        end

        err = FT_Load_Char(face, char.ord, FreeType::C::FT_LOAD_DEFAULT)
        if err != 0
          t.error FreeType::Error.find(err).message
        end

        size = face[:size]
        unless FT_SizeRec === size
          t.error 'Miss Struct bind'
        end

        size_metrics = face[:size][:metrics]
        unless FT_Size_Metrics === size_metrics
          t.error 'Miss Struct bind'
        end

        glyph = face[:glyph]
        unless FT_GlyphSlotRec === glyph
          t.error 'Miss Struct bind'
        end

        glyph_metrics = face[:glyph][:metrics]
        unless FT_Glyph_Metrics === glyph_metrics
          t.error 'Miss Struct bind'
        end

        outline = face[:glyph][:outline]
        unless 0 <= outline[:n_points]
          t.error "n_outline:#{outline[:n_points]} Cannot get FT_Outline.n_prints member from ffi"
        end

        unless 0 <= outline[:n_contours]
          t.error "n_contours:#{outline[:n_contours]} Cannot get FT_Outline.n_contours member from ffi"
        end

        end_ptd_of_counts = outline[:contours].get_array_of_short(0, outline[:n_contours])

        unless end_ptd_of_counts.all? { |i| Fixnum === i }
          t.error 'FT_Outline.contours is array if short. broken or fail when get form ffi.'
        end

        tags = outline[:tags].get_array_of_char(0, outline[:n_points])
        unless tags.all? { |i| Fixnum === i }
          t.error 'FT_Outline.tags is array of char. broken or fail when get form ffi.'
        end

        points = outline[:n_points].times.map do |i|
          FT_Vector.new(outline[:points] + i * FT_Vector.size)
        end

        points.each do |i|
          unless i[:x].kind_of?(Fixnum) && i[:y].kind_of?(Fixnum)
            t.error('Miss assignment from ffi')
          end
        end

        before_glyph_id = glyph_id
      end
    end
  end
end
