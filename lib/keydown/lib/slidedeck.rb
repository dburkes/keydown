module Keydown
  class SlideDeck

    attr_reader :title
    attr_reader :slides

    def initialize(text)
      @title = ''
      @slides = []
      @text = text

      set_title
      extract_classnames!
      build_slides
    end

    def to_html
      require 'erb'

      css_files = ['css/keydown.css']
      css_files += Dir.glob('css/*.css')
      css_files.uniq!
      css_files -= ['css/rocks.css']
      js_files = Dir.glob('js/*.js') - ['js/rocks.js']

      template = File.new(File.join(Tasks.template_dir, 'index.rhtml'))
      ERB.new(template.read).result(binding)
    end

    private

    def set_title
      match_data = @text.match(/\A\s*#\s*(.*)$/)

      @title = match_data[1] if match_data
    end

    def extract_classnames!
      @classnames = []
      @text.gsub!(/^!SLIDE\s*([\w\s\-]*)\n/m) do
        @classnames << $1.chomp
        "!SLIDE\n"
      end
    end

    def build_slides
      slides_text = @text.split(/!SLIDE/).reject { |s| s.empty? }
      slides_text[1..-1].each_with_index do |slide_text, i|
        slide_text.gsub(/\A(\n+)/, '').chomp!
        @slides << Keydown::Slide.new(slide_text, @classnames[i])
      end
    end
  end

end