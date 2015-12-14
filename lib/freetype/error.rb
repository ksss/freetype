module FreeType
  # Error collection defined by freetype error
  class Error < StandardError
    attr_reader :code, :message
    def initialize(code, message)
      @code = code
      @message = message
    end

    class << self
      # err = FT_Init_FreeType(library)
      # raise Error.find(err) unless err == 0
      def find(code)
        klass, code, message = ERRORS[code]
        if klass
          klass.new(code, message)
        else
          nil
        end
      end
    end

    # $ cat /usr/local/Cellar/freetype/2.6_1/include/freetype2/fterrdef.h | ruby -e 'print $stdin.read.gsub(/,\n|[,()]/m, "")'| grep ERRORDEF | awk '{print $3 " => [("$2 " = Class.new(Error)), " $3 ", " $4" "$5" "$6" "$7" "$8" "$9 " "$10" "$11" "$12"],"}' | pbcopy
    ERRORS = {
      0x00 => [(Ok = Class.new(Error)), 0x00, 'no error'],
      0x01 => [(Cannot_Open_Resource = Class.new(Error)), 0x01, 'cannot open resource'],
      0x02 => [(Unknown_File_Format = Class.new(Error)), 0x02, 'unknown file format'],
      0x03 => [(Invalid_File_Format = Class.new(Error)), 0x03, 'broken file'],
      0x04 => [(Invalid_Version = Class.new(Error)), 0x04, 'invalid FreeType version'],
      0x05 => [(Lower_Module_Version = Class.new(Error)), 0x05, 'module version is too low'],
      0x06 => [(Invalid_Argument = Class.new(Error)), 0x06, 'invalid argument'],
      0x07 => [(Unimplemented_Feature = Class.new(Error)), 0x07, 'unimplemented feature'],
      0x08 => [(Invalid_Table = Class.new(Error)), 0x08, 'broken table'],
      0x09 => [(Invalid_Offset = Class.new(Error)), 0x09, 'broken offset within table'],
      0x0A => [(Array_Too_Large = Class.new(Error)), 0x0A, 'array allocation size too large'],
      0x0B => [(Missing_Module = Class.new(Error)), 0x0B, 'missing module'],
      0x0C => [(Missing_Property = Class.new(Error)), 0x0C, 'missing property'],
      0x10 => [(Invalid_Glyph_Index = Class.new(Error)), 0x10, 'invalid glyph index'],
      0x11 => [(Invalid_Character_Code = Class.new(Error)), 0x11, 'invalid character code'],
      0x12 => [(Invalid_Glyph_Format = Class.new(Error)), 0x12, 'unsupported glyph image format'],
      0x13 => [(Cannot_Render_Glyph = Class.new(Error)), 0x13, 'cannot render this glyph format'],
      0x14 => [(Invalid_Outline = Class.new(Error)), 0x14, 'invalid outline'],
      0x15 => [(Invalid_Composite = Class.new(Error)), 0x15, 'invalid composite glyph'],
      0x16 => [(Too_Many_Hints = Class.new(Error)), 0x16, 'too many hints'],
      0x17 => [(Invalid_Pixel_Size = Class.new(Error)), 0x17, 'invalid pixel size'],
      0x20 => [(Invalid_Handle = Class.new(Error)), 0x20, 'invalid object handle'],
      0x21 => [(Invalid_Library_Handle = Class.new(Error)), 0x21, 'invalid library handle'],
      0x22 => [(Invalid_Driver_Handle = Class.new(Error)), 0x22, 'invalid module handle'],
      0x23 => [(Invalid_Face_Handle = Class.new(Error)), 0x23, 'invalid face handle'],
      0x24 => [(Invalid_Size_Handle = Class.new(Error)), 0x24, 'invalid size handle'],
      0x25 => [(Invalid_Slot_Handle = Class.new(Error)), 0x25, 'invalid glyph slot handle'],
      0x26 => [(Invalid_CharMap_Handle = Class.new(Error)), 0x26, 'invalid charmap handle'],
      0x27 => [(Invalid_Cache_Handle = Class.new(Error)), 0x27, 'invalid cache manager handle'],
      0x28 => [(Invalid_Stream_Handle = Class.new(Error)), 0x28, 'invalid stream handle'],
      0x30 => [(Too_Many_Drivers = Class.new(Error)), 0x30, 'too many modules'],
      0x31 => [(Too_Many_Extensions = Class.new(Error)), 0x31, 'too many extensions'],
      0x40 => [(Out_Of_Memory = Class.new(Error)), 0x40, 'out of memory'],
      0x41 => [(Unlisted_Object = Class.new(Error)), 0x41, 'unlisted object'],
      0x51 => [(Cannot_Open_Stream = Class.new(Error)), 0x51, 'cannot open stream'],
      0x52 => [(Invalid_Stream_Seek = Class.new(Error)), 0x52, 'invalid stream seek'],
      0x53 => [(Invalid_Stream_Skip = Class.new(Error)), 0x53, 'invalid stream skip'],
      0x54 => [(Invalid_Stream_Read = Class.new(Error)), 0x54, 'invalid stream read'],
      0x55 => [(Invalid_Stream_Operation = Class.new(Error)), 0x55, 'invalid stream operation'],
      0x56 => [(Invalid_Frame_Operation = Class.new(Error)), 0x56, 'invalid frame operation'],
      0x57 => [(Nested_Frame_Access = Class.new(Error)), 0x57, 'nested frame access'],
      0x58 => [(Invalid_Frame_Read = Class.new(Error)), 0x58, 'invalid frame read'],
      0x60 => [(Raster_Uninitialized = Class.new(Error)), 0x60, 'raster uninitialized'],
      0x61 => [(Raster_Corrupted = Class.new(Error)), 0x61, 'raster corrupted'],
      0x62 => [(Raster_Overflow = Class.new(Error)), 0x62, 'raster overflow'],
      0x63 => [(Raster_Negative_Height = Class.new(Error)), 0x63, 'negative height while rastering'],
      0x70 => [(Too_Many_Caches = Class.new(Error)), 0x70, 'too many registered caches'],
      0x80 => [(Invalid_Opcode = Class.new(Error)), 0x80, 'invalid opcode'],
      0x81 => [(Too_Few_Arguments = Class.new(Error)), 0x81, 'too few arguments'],
      0x82 => [(Stack_Overflow = Class.new(Error)), 0x82, 'stack overflow'],
      0x83 => [(Code_Overflow = Class.new(Error)), 0x83, 'code overflow'],
      0x84 => [(Bad_Argument = Class.new(Error)), 0x84, 'bad argument'],
      0x85 => [(Divide_By_Zero = Class.new(Error)), 0x85, 'division by zero'],
      0x86 => [(Invalid_Reference = Class.new(Error)), 0x86, 'invalid reference'],
      0x87 => [(Debug_OpCode = Class.new(Error)), 0x87, 'found debug opcode'],
      0x88 => [(ENDF_In_Exec_Stream = Class.new(Error)), 0x88, 'found ENDF opcode in execution stream'],
      0x89 => [(Nested_DEFS = Class.new(Error)), 0x89, 'nested DEFS'],
      0x8A => [(Invalid_CodeRange = Class.new(Error)), 0x8A, 'invalid code range'],
      0x8B => [(Execution_Too_Long = Class.new(Error)), 0x8B, 'execution context too long'],
      0x8C => [(Too_Many_Function_Defs = Class.new(Error)), 0x8C, 'too many function definitions'],
      0x8D => [(Too_Many_Instruction_Defs = Class.new(Error)), 0x8D, 'too many instruction definitions'],
      0x8E => [(Table_Missing = Class.new(Error)), 0x8E, 'SFNT font table missing'],
      0x8F => [(Horiz_Header_Missing = Class.new(Error)), 0x8F, 'horizontal header hhea table missing'],
      0x90 => [(Locations_Missing = Class.new(Error)), 0x90, 'locations loca table missing'],
      0x91 => [(Name_Table_Missing = Class.new(Error)), 0x91, 'name table missing'],
      0x92 => [(CMap_Table_Missing = Class.new(Error)), 0x92, 'character map cmap table missing'],
      0x93 => [(Hmtx_Table_Missing = Class.new(Error)), 0x93, 'horizontal metrics hmtx table missing'],
      0x94 => [(Post_Table_Missing = Class.new(Error)), 0x94, 'PostScript post table missing'],
      0x95 => [(Invalid_Horiz_Metrics = Class.new(Error)), 0x95, 'invalid horizontal metrics'],
      0x96 => [(Invalid_CharMap_Format = Class.new(Error)), 0x96, 'invalid character map cmap format'],
      0x97 => [(Invalid_PPem = Class.new(Error)), 0x97, 'invalid ppem value'],
      0x98 => [(Invalid_Vert_Metrics = Class.new(Error)), 0x98, 'invalid vertical metrics'],
      0x99 => [(Could_Not_Find_Context = Class.new(Error)), 0x99, 'could not find context'],
      0x9A => [(Invalid_Post_Table_Format = Class.new(Error)), 0x9A, 'invalid PostScript post table format'],
      0x9B => [(Invalid_Post_Table = Class.new(Error)), 0x9B, 'invalid PostScript post table'],
      0xA0 => [(Syntax_Error = Class.new(Error)), 0xA0, 'opcode syntax error'],
      0xA1 => [(Stack_Underflow = Class.new(Error)), 0xA1, 'argument stack underflow'],
      0xA2 => [(Ignore = Class.new(Error)), 0xA2, 'ignore'],
      0xA3 => [(No_Unicode_Glyph_Name = Class.new(Error)), 0xA3, 'no Unicode glyph name found'],
      0xA4 => [(Glyph_Too_Big = Class.new(Error)), 0xA4, 'glyph to big for hinting'],
      0xB0 => [(Missing_Startfont_Field = Class.new(Error)), 0xB0, "`STARTFONT' field missing"],
      0xB1 => [(Missing_Font_Field = Class.new(Error)), 0xB1, "`FONT' field missing"],
      0xB2 => [(Missing_Size_Field = Class.new(Error)), 0xB2, "`SIZE' field missing"],
      0xB3 => [(Missing_Fontboundingbox_Field = Class.new(Error)), 0xB3, "`FONTBOUNDINGBOX' field missing"],
      0xB4 => [(Missing_Chars_Field = Class.new(Error)), 0xB4, "`CHARS' field missing"],
      0xB5 => [(Missing_Startchar_Field = Class.new(Error)), 0xB5, "`STARTCHAR' field missing"],
      0xB6 => [(Missing_Encoding_Field = Class.new(Error)), 0xB6, "`ENCODING' field missing"],
      0xB7 => [(Missing_Bbx_Field = Class.new(Error)), 0xB7, "`BBX' field missing"],
      0xB8 => [(Bbx_Too_Big = Class.new(Error)), 0xB8, "`BBX' too big"],
      0xB9 => [(Corrupted_Font_Header = Class.new(Error)), 0xB9, 'Font header corrupted or missing fields'],
      0xBA => [(Corrupted_Font_Glyphs = Class.new(Error)), 0xBA, 'Font glyphs corrupted or missing fields'],
    }
  end
end
