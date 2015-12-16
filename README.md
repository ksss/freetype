# FreeType

[![Build Status](https://travis-ci.org/ksss/freetype.svg?branch=master)](https://travis-ci.org/ksss/freetype)

FreeType is freetype wrapper using by ffi

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'freetype'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install freetype

## Usage

### Low Level API

```ruby
require 'freetype/c'

include FreeType::C

library = FFI::MemoryPointer.new(:pointer)
err = FT_Init_FreeType(library)
raise FreeType::Error.find(err) unless err == 0

face = FFI::MemoryPointer.new(:pointer)
err = FT_New_Face(library.get_pointer(0), 'font.otf', 0, face)
raise FreeType::Error.find(err) unless err == 0

err = FT_Set_Char_Size(face.get_pointer(0), 0, 32 * 32, 300, 300)
raise FreeType::Error.find(err) unless err == 0

err = FT_Load_Char(face.get_pointer(0), 'a'.ord, FT_LOAD_DEFAULT)
raise FreeType::Error.find(err) unless err == 0

face_rec = FT_FaceRec.new face.get_pointer(0)
outline = face_rec[:glyph][:outline]

points = outline[:n_points].times.map do |i|
  FT_Vector.new(outline[:points] + i * FT_Vector.size)
end

tags = outline[:tags].get_array_of_char(0, outline[:n_points])

points.zip(tags).each do |(point, tag)|
  p point[:x] #=> 10
  p point[:y] #=> 24
  p tag #=> -1
end

v = FT_Vector.new
err = FT_Get_Kerning(
  face.get_pointer(0),
  FT_Get_Char_Index(face.get_pointer(0), 'A'.ord),
  FT_Get_Char_Index(face.get_pointer(0), 'W'.ord),
  :FT_KERNING_UNFITTED,
  v
)
p v[:x] #=> -10
p v[:y] #=> 0

err = FT_Done_Face(face.get_pointer(0))
raise FreeType::Error.find(err) unless err == 0

err = FT_Done_Library(library.get_pointer(0))
raise FreeType::Error.find(err) unless err == 0
```

### High Level API

```ruby
require 'freetype/api'

include FreeType::API

Library.open do |lib|
  lib.face_open('font.ttf') do |face|
    face.set_char_size(0, 32 * 32, 300, 300)
    outline = face.outline('a')
    p outline.points #=> [#<FreeType::API::Outline tag=-1 x= 10 y=24>, ...]
    p face.kerning_unfitted('A', 'W') #=> #<FreeType::API::Vector x=-10 y=0>
  end
end
```

### Use All

```ruby
require 'freetype'

FreeType::API::Library.open do |lib|
  face = FFI::MemoryPointer.new(:pointer)
  FreeType::C::FT_New_Face(lib.pointer, 'font.otf', 0, face)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/freetype. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Reference

FreeType: http://www.freetype.org/
