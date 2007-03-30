require 'controllers/sprint_sensor'
require 'rubygems'
require 'models/racer'
require 'builder'
require 'gtkmozembed'
require 'units/standard'

RED_TRACK_LENGTH = 1315
BLUE_TRACK_LENGTH = 1200
RED_WHEEL_CIRCUMFERENCE = 2097.mm.to_km
BLUE_WHEEL_CIRCUMFERENCE = 2097.mm.to_km

class DashboardController
  def initialize
    style
    @dial_90_degrees = 8
    @dial_180_degrees = 24
    @dial_270_degrees = 40
    @red = Racer.new(:wheel_circumference => 2097.mm.to_km,
                     :track_length => 1315, :yaml_name => 'rider-one-tick')
    @blue = Racer.new(:wheel_circumference => 2097.mm.to_km,
                    :track_length => 1315, :yaml_name => 'rider-two-tick')
    @laps = 1
    @doc = build_template
  end
  def quadrantificate(offset, total, distance=0)
    if distance > offset
      [0,0,offset,((total-offset)-(distance-offset))]
    else
      [0,(offset-distance),distance,(total-offset)]
    end
  end
  def speed_to_angle(speed)
    unadjusted = ((speed/48.0)*270.0+45.0)
    unadjusted-180
  end
  def read_blue
    @blue.update(@sensor.read_blue)
    track = BLUE_TRACK_LENGTH*@blue.distance
    @blue_dasharray = quadrantificate(700, BLUE_TRACK_LENGTH, track).join(',')
    @blue_pointer_angle = speed_to_angle(@blue.speed)
  end
  def read_red
    @red.update(@sensor.read_red)
    track = RED_TRACK_LENGTH*@red.distance
    @red_dasharray = quadrantificate(765, RED_TRACK_LENGTH, track).join(',')
    @red_pointer_angle = speed_to_angle(@red.speed)
  end
  def style
    File.open('views/style.css') do |f|
      @stylishness = f.readlines.join
    end
  end
  def build_template
    xml_data = ''
    xml = Builder::XmlMarkup.new(:target => xml_data)
    svg = ''
    File.open('views/svg.rb') do |f|
      svg = f.readlines.join
    end
    eval svg
    doc = ''
    File.open('views/wrap.html') do |f|
      doc = f.readlines.join
    end 
    @wrap = doc
    doc = doc % xml_data
    doc.gsub!(/%([^s])/,'%%\1')
  end
  def begin_logging
    @sensor = SprintSensor.new
  end
  def refresh
    ret = ''
    read_red
    read_blue
    if @blue.distance>1.0 or @red.distance>1.0
      winner = (@red.distance>@blue.distance) ? 'RED' : 'BLUE'
      ret = [@wrap % "<h1>#{winner} WINS!</h1>","http://foo","text/html"]
      @continue = false
    else
      ret = [@doc % [@red_dasharray, @blue_dasharray, @blue_pointer_angle,
              @red_pointer_angle],"http://foo","application/xml"]
      @continue = true
    end
    ret
  end
  def continue?
    @continue
  end
  def count(n)
    @wrap % "<h1>#{n}....</h1>"
  end
end
dashboard_controller = DashboardController.new
@w = Gtk::Window.new
@w.title = "IRO Sprints"
@w.resize(760, 570)
box = Gtk::VBox.new(false, 0)
moz = Gtk::MozEmbed.new
moz.chrome_mask = Gtk::MozEmbed::ALLCHROME
countdown = 5
Gtk.timeout_add(1000) do
  case countdown
  when (1..5)
    moz.render_data(dashboard_controller.count(countdown),
                      "http://foo","text/html")
    countdown-=1
    true
  when 0
    dashboard_controller.begin_logging
    Gtk.timeout_add(500) do
      moz.render_data(*(dashboard_controller.refresh))
      dashboard_controller.continue?
    end
    false    
  end
end
@w.signal_connect("destroy") do
  Gtk.main_quit
end
box.pack_start(moz)
@w << box
@w.show_all
Gtk.main