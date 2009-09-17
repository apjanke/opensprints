if defined? Shoes
  Shoes.setup do
    gem "activesupport"
    gem "bacon"
    gem "dm-core"
    gem "dm-aggregates"
    gem "do_sqlite3"
  end
end
 
module MainHelper
  def button(text, styles={}, &callback)
    stack(:height => 32, :width => styles[:width]||(40+(text.length * 8)), :margin => [5,10,5,0], :padding_top => 0) do
      background(styles[:fill]||gray(0.2,0.5), :curve => 5)
      t = inscription(text, :align => styles[:align]||'center', :stroke => styles[:stroke]||white)
      click &callback
      hover {
        t.underline = 'single'
      }
      leave {
        t.underline = 'none'
      }
    end
  end

  def left_button(text, styles={}, &callback)
    button(text, styles.merge({:width => 1.0, :align => 'left'}), &callback)
  end

  def light_button(text, styles={}, &callback)
    button(text, styles.merge({:fill => rgb(200,200,200,0.7), :stroke => rgb(50,50,50)}), &callback)
  end

  def container
    background(gray(0.3,0.5), :curve => 10)
    border(gray, :curve => 10, :strokewidth => 3)
    border(black, :curve => 10, :strokewidth => 1)
  end

  def session
    if(defined?(@@session) && @@session)
      @@session
    else
      @@session = {:referrer => []}
    end
  end

  def separator_line(n=45)
    flow(:height => 18, :scroll => false) do
      n.times { inscription '-', :margin => 4, :stroke => gray(0.8) }
    end
  end
end

class Main < Shoes
  url '/', :index

  include MainHelper

  def custom_styles
    if Shoes::FONTS.grep(/Avenir/).any?
      default_font = "Avenir Black"
    else
      default_font = "Delicious Heavy"
    end
    style(Banner,     :size => 48, :stroke => white, :font => default_font)
    style(Title,      :size => 34, :stroke => white, :font => default_font)
    style(Subtitle,   :size => 26, :stroke => white, :font => default_font)
    style(Tagline,    :size => 18, :stroke => white, :font => default_font)
    style(Caption,    :size => 14, :stroke => white, :font => default_font)
    style(Para,       :size => 12, :margin => [0]*4, :weight => "Bold", :stroke => white, :font => default_font)
    style(Inscription,:size => 10, :stroke => white, :margin => [0]*4, :font => default_font)

    style(Code,       :family => 'monospace')
    style(Del,        :strikethrough => 'single')
    style(Em,         :emphasis => 'italic')
    style(Ins,        :underline => 'single')
    style(Link,       :underline => 'none', :stroke => white)
    style(LinkHover,  :underline => 'single',  :stroke => white)
    style(Strong,     :weight => 'bold')
    style(Sup,        :rise =>   10,        :size =>  'x-small')
    style(Sub,        :rise =>   -10, :size => 'x-small')
  end
  

  def index
    layout
    @nav.clear {
      button("categories") { visit "/categories"}
      button("events") { visit "/tournaments"}
      button("configuration") { visit "/configuration"}
    }
  end

  def nav
    @nav = flow(:attach => Window, :top => 0, :left => 20) {
      button("Return to Main Menu") { visit "/" }
    }
  end

  def layout(background_type=:normal)
    custom_styles
    background BACKGROUND_COLOR if(defined?(BACKGROUND_COLOR))
    if(background_type==:menu)
      background MENU_BACKGROUND_IMAGE if(defined?(MENU_BACKGROUND_IMAGE))
    else
      background BACKGROUND_IMAGE if(defined?(BACKGROUND_IMAGE))
    end
    nav
    @header = flow do
      banner TITLE
    end
    @left = stack(:width => 150) do
    end
    @center = flow(:width => width - (175+125), :height => HEIGHT-@header.height-150) do
    end
    @right = flow(:width => 150) do
    end
  end

end
#YAY HAPPY FUN TIME UN-NAMESPACING
Kernel::Main = Main

require 'lib/setup.rb'

Shoes.app(:height => HEIGHT, :width => WIDTH, :scroll => false, :title => TITLE)
