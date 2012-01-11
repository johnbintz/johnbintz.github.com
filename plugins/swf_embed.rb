if false
module Jekyll
  class SWFEmbed < Liquid::Tag
  end
end

Liquid::Template.register_tag('swf', Jekyll::SWFEmbed)
end
