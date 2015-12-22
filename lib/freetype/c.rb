require 'ffi'

module FreeType
  # low level APIs call by FFI
  module C
    extend ::FFI::Library
    ffi_lib ['libfreetype.dylib', 'libfreetype.6.dylib', 'freetype.so', 'freetype.so.6', 'freetype']
    typedef :long, :FT_Pos
    typedef :long, :FT_Fixed
    typedef :long, :FT_F26Dot6
    typedef :int, :FT_Error

    FT_ENC_TAG = lambda do |a, b, c, d|
      [a, b, c, d].map(&:ord).inject(0) { |r, i| (r << 8) + i }
    end

    FT_IMAGE_TAG = FT_ENC_TAG

    # http://www.freetype.org/freetype2/docs/reference/ft2-basic_types.html#FT_Glyph_Format
    FT_Glyph_Format = enum(
      :FT_GLYPH_FORMAT_NONE, 0,
      :FT_GLYPH_FORMAT_COMPOSITE, FT_IMAGE_TAG['c', 'o', 'm', 'p'],
      :FT_GLYPH_FORMAT_BITMAP,    FT_IMAGE_TAG['b', 'i', 't', 's'],
      :FT_GLYPH_FORMAT_OUTLINE,   FT_IMAGE_TAG['o', 'u', 't', 'l'],
      :FT_GLYPH_FORMAT_PLOTTER,   FT_IMAGE_TAG['p', 'l', 'o', 't'],
    )

    # http://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_Kerning_Mode
    FT_Kerning_Mode = enum(
      :FT_KERNING_DEFAULT, 0,
      :FT_KERNING_UNFITTED,
      :FT_KERNING_UNSCALED,
    )

    FT_Encoding = enum(
      :FT_ENCODING_NONE, 0,
      :FT_ENCODING_MS_SYMBOL,      FT_ENC_TAG['s', 'y', 'm', 'b'],
      :FT_ENCODING_UNICODE,        FT_ENC_TAG['u', 'n', 'i', 'c'],
      :FT_ENCODING_SJIS,           FT_ENC_TAG['s', 'j', 'i', 's'],
      :FT_ENCODING_GB2312,         FT_ENC_TAG['g', 'b', ' ', ' '],
      :FT_ENCODING_BIG5,           FT_ENC_TAG['b', 'i', 'g', '5'],
      :FT_ENCODING_WANSUNG,        FT_ENC_TAG['w', 'a', 'n', 's'],
      :FT_ENCODING_JOHAB,          FT_ENC_TAG['j', 'o', 'h', 'a'],
      :FT_ENCODING_ADOBE_STANDARD, FT_ENC_TAG['A', 'D', 'O', 'B'],
      :FT_ENCODING_ADOBE_EXPERT,   FT_ENC_TAG['A', 'D', 'B', 'E'],
      :FT_ENCODING_ADOBE_CUSTOM,   FT_ENC_TAG['A', 'D', 'B', 'C'],
      :FT_ENCODING_ADOBE_LATIN_1,  FT_ENC_TAG['l', 'a', 't', '1'],
      :FT_ENCODING_OLD_LATIN_2,    FT_ENC_TAG['l', 'a', 't', '2'],
      :FT_ENCODING_APPLE_ROMAN,    FT_ENC_TAG['a', 'r', 'm', 'n'],
    )

    # http://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_LOAD_XXX
    FT_LOAD_DEFAULT                      = 0x0
    FT_LOAD_NO_SCALE                     = 1 << 0
    FT_LOAD_NO_HINTING                   = 1 << 1
    FT_LOAD_RENDER                       = 1 << 2
    FT_LOAD_NO_BITMAP                    = 1 << 3
    FT_LOAD_VERTICAL_LAYOUT              = 1 << 4
    FT_LOAD_FORCE_AUTOHINT               = 1 << 5
    FT_LOAD_CROP_BITMAP                  = 1 << 6
    FT_LOAD_PEDANTIC                     = 1 << 7
    FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH  = 1 << 9
    FT_LOAD_NO_RECURSE                   = 1 << 10
    FT_LOAD_IGNORE_TRANSFORM             = 1 << 11
    FT_LOAD_MONOCHROME                   = 1 << 12
    FT_LOAD_LINEAR_DESIGN                = 1 << 13
    FT_LOAD_NO_AUTOHINT                  = 1 << 15
    FT_LOAD_COLOR                        = 1 << 20
    FT_LOAD_COMPUTE_METRICS              = 1 << 21

    # http://www.freetype.org/freetype2/docs/reference/ft2-basic_types.html#FT_BBox
    class FT_BBox < ::FFI::Struct
      layout xMin: :FT_Pos,
             yMin: :FT_Pos,
             xMax: :FT_Pos,
             yMax: :FT_Pos
    end

    # http://www.freetype.org/freetype2/docs/reference/ft2-basic_types.html#FT_Bitmap
    class FT_Bitmap < ::FFI::Struct
      layout rows: :uint,
             width: :uint,
             pitch: :int,
             buffer: :pointer,
             num_grays: :ushort,
             pixel_mode: :char,
             palette_mode: :char,
             palette: :pointer
    end

    # http://www.freetype.org/freetype2/docs/reference/ft2-basic_types.html#FT_Generic
    class FT_Generic < ::FFI::Struct
      layout data: :pointer,
             finalizer: :pointer
    end

    # http://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_Glyph_Metrics
    class FT_Glyph_Metrics < ::FFI::Struct
      layout width: :FT_Pos,
             height: :FT_Pos,
             horiBearingX: :FT_Pos,
             horiBearingY: :FT_Pos,
             horiAdvance: :FT_Pos,
             vertBearingX: :FT_Pos,
             vertBearingY: :FT_Pos,
             vertAdvance: :FT_Pos
    end

    # http://www.freetype.org/freetype2/docs/reference/ft2-outline_processing.html#FT_Outline
    class FT_Outline < ::FFI::Struct
      layout n_contours: :short,
             n_points: :short,
             points: :pointer, # FT_Vector* (n_points)
             tags: :pointer, # char * (n_points)
             contours: :pointer, # short * (n_contours)
             # http://www.freetype.org/freetype2/docs/reference/ft2-outline_processing.html#FT_OUTLINE_XXX
             flags: :int
    end

    # http://www.freetype.org/freetype2/docs/reference/ft2-basic_types.html#FT_Vector
    class FT_Vector < ::FFI::Struct
      layout x: :FT_Pos,
             y: :FT_Pos
    end

    # http://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_GlyphSlotRec
    class FT_GlyphSlotRec < ::FFI::Struct
      layout library: :pointer,
             face: :pointer,
             next: :pointer,
             reserved: :uint,
             generic: FT_Generic,
             metrics: FT_Glyph_Metrics,
             linearHoriAdvance: :FT_Fixed,
             linearVertAdvance: :FT_Fixed,
             advance: FT_Vector,
             format: FT_Glyph_Format,
             bitmap: FT_Bitmap,
             bitmap_left: :int,
             bitmap_top: :int,
             outline: FT_Outline,
             num_subglyphs: :uint,
             subglyphs: :pointer, # FT_SubGlyph
             control_data: :pointer, # void *
             control_len: :long,
             lsb_delta: :FT_Pos,
             rsb_delta: :FT_Pos,
             other: :pointer, # void *
             internal: :pointer #  FT_Slot_Internal
    end

    # http://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_Size_Metrics
    class FT_Size_Metrics < ::FFI::Struct
      layout x_ppem: :ushort,
             y_ppem: :ushort,
             x_scale: :FT_Fixed,
             y_scale: :FT_Fixed,
             ascender: :FT_Pos,
             descender: :FT_Pos,
             height: :FT_Pos,
             max_advance: :FT_Pos
    end

    # http://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_SizeRec
    class FT_SizeRec < ::FFI::Struct
      layout face: :pointer, # FT_Face
             generic: FT_Generic,
             metrics: FT_Size_Metrics,
             internal: :pointer # FT_Size_Internal
    end

    class FT_CharMapRec < ::FFI::Struct
      layout face: :pointer,
             encoding: FT_Encoding,
             platform_id: :ushort,
             encoding_id: :ushort
    end

    # http://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_FaceRec
    class FT_FaceRec < ::FFI::Struct
      layout num_faces: :long,
             face_index: :long,
             face_flags: :long,
             style_flags: :long,
             num_glyphs: :long,
             family_name: :string,
             style_name: :string,
             num_fixed_sizes: :int,
             available_sizes: :pointer, # FT_Bitmap_Size*
             num_charmaps: :int,
             charmaps: FT_CharMapRec.ptr,
             generic: FT_Generic,
             bbox: FT_BBox,
             units_per_EM: :ushort,
             ascender: :short,
             descender: :short,
             height: :short,
             max_advance_width: :short,
             max_advance_height: :short,
             underline_position: :short,
             underline_thickness: :short,
             glyph: FT_GlyphSlotRec.ptr,
             size: FT_SizeRec.ptr,
             charmap: :pointer
    end

    # library = FFI::MemoryPointer.new(:pointer)
    # err = FT_Init_FreeType(library)
    # err = FT_Done_Library(library.get_pointer(0))
    attach_function :FT_Init_FreeType, [:pointer], :FT_Error
    attach_function :FT_Done_Library, [:pointer], :FT_Error
    attach_function :FT_Library_Version, [:pointer, :pointer, :pointer, :pointer], :void

    # face = FFI::MemoryPointer.new(:pointer)
    # err = FT_New_Face(library.get_pointer(0), 'font.otf', 0, face)
    # face = FT_FaceRec.new(face.get_pointer(0))
    # err = FT_Done_Face(face)
    attach_function :FT_New_Face, [:pointer, :string, :long, :pointer], :FT_Error
    attach_function :FT_Done_Face, [:pointer], :FT_Error

    # err = FT_Set_Char_Size(face, 0, 36 * 64, 300, 300)
    attach_function :FT_Set_Char_Size, [:pointer, :FT_F26Dot6, :FT_F26Dot6, :uint, :uint], :FT_Error

    # err = FT_Select_Charmap(face, :FT_ENCODING_UNICODE)
    attach_function :FT_Select_Charmap, [:pointer, FT_Encoding], :FT_Error

    # err = FT_Load_Char(face, 'Q'.ord, FreeType::FT_LOAD_DEFAULT)
    attach_function :FT_Load_Char, [:pointer, :ulong, :int32], :FT_Error

    # err = FT_Load_Glyph(face, 0, FT_LOAD_DEFAULT)
    # attach_function :FT_Load_Glyph, [FT_FaceRec.ptr, :uint, :int32], :FT_Error
    # attach_function :FT_Get_Glyph, [FT_GlyphSlotRec.ptr, :pointer], :FT_Error
    # attach_function :FT_Done_Glyph, [:pointer], :void

    attach_function :FT_GlyphSlot_Embolden, [FT_GlyphSlotRec.ptr], :void
    attach_function :FT_GlyphSlot_Oblique, [FT_GlyphSlotRec.ptr], :void
    attach_function :FT_Outline_Embolden, [:pointer, :FT_Pos], :FT_Error
    # id = FT_Get_Char_Index(face, 'A'.ord) -> glyph id or 0 (undefined)
    attach_function :FT_Get_Char_Index, [:pointer, :ulong], :uint

    # err = FT_Get_Glyph_Name(face, 0, buff, 32)
    attach_function :FT_Get_Glyph_Name, [:pointer, :uint, :pointer, :uint], :FT_Error

    # v = FT_Vector.new
    # err = FT_Get_Kerning(face, before_id, id, :FT_KERNING_DEFAULT, v)
    # p v
    attach_function :FT_Get_Kerning, [:pointer, :uint, :uint, :uint, :pointer], :FT_Error
  end
end
