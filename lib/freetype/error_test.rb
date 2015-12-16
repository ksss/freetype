require 'freetype/error'

module FreeTypeErrorTest
  def test_all(t)
    FreeType::Error::ERRORS.each do |code, (klass, _code, message)|
      err = FreeType::Error.find(code)
      unless FreeType::Error === err
        t.error('Error code miss generate')
      end
      unless err.class == klass
        t.error('Error.find return object miss')
      end
      unless err.code == _code
        t.error('Error.find return object miss')
      end
      unless err.message == message
        t.error('Error.find return object miss')
      end
    end
  end
end
