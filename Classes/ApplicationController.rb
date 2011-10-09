require 'open-uri'
require 'json'
framework 'CoreLocation'

class ApplicationController
  KInternetEventClass = KAEGetURL = 'GURL'.unpack('N').first
  KeyDirectObject = '----'.unpack('N').first

  attr_accessor :menu

  def awakeFromNib
    @status_bar  = NSStatusBar.systemStatusBar
    @status_item = @status_bar.statusItemWithLength(NSVariableStatusItemLength)
    @status_item.setHighlightMode(true)
    @menu = NSMenu.alloc.initWithTitle(initWithTitle:"DockMenu")
    @menu.setAutoenablesItems(false)

    @skullspace = CLLocation.alloc.initWithLatitude(49.8996690, longitude: -97.14234410)

    @status_item.setMenu(@menu)

    @app_empty_icon         = NSImage.imageNamed('skullspace-empty.png')
    @app_empty_alter_icon   = NSImage.imageNamed('skullspace-empty-alt.png')
    @app_full_icon          = NSImage.imageNamed('skullspace-full.png')
    @app_full_alter_icon    = NSImage.imageNamed('skullspace-full-alt.png')
    @app_problem_icon       = NSImage.imageNamed('skullspace-problem.png')
    @app_problem_alter_icon = NSImage.imageNamed('skullspace-problem-alt.png')

    @status_item.setImage(@app_problem_icon)
    @status_item.setAlternateImage(@app_problem_alter_icon)

    @location_menu_item = NSMenuItem.alloc.init
    @location_menu_item.setTarget(self)
    @location_menu_item.setEnabled(false)
    @location_menu_item.title = "N/A"

    @quit_menu_item = NSMenuItem.alloc.init
    @quit_menu_item.setTarget(self)
    @quit_menu_item.title = "Quit"
    @quit_menu_item.setAction "cleanupAndQuit:"

    @menu.addItem @location_menu_item
    @menu.addItem @quit_menu_item

    Thread.new do
      loop do
        updateStatus
        sleep 10
      end
    end

    loc = CLLocationManager.alloc.init
    loc.delegate = self
    loc.startUpdatingLocation
  end

  def cleanupAndQuit(sender)
    exit
  end

  def locationManager(manager, didUpdateToLocation: new_location, fromLocation: old_location)
    # 49.8996690
    # 97.14234410
    # "formatted_address" : "125 Adelaide St, Winnipeg, MB R3A 0H7, Canada",
    meters_from_skullspace =  new_location.distanceFromLocation @skullspace
    km_from_skullspace = meters_from_skullspace/1000
    @location_menu_item.title = "#{km_from_skullspace.round(2)} km from Skullspace"
  end

  def updateStatus
    begin
      case open("http://isthereanyoneatskullspace.com/index.txt").read
      when /YES/
        setFull
      when /NO/
        setEmpty
      else
        setProblem
      end
    rescue
      setProblem
    end
  end

  def setProblem
    @status_item.setImage(@app_problem_icon)
    @status_item.setAlternateImage(@app_problem_alter_icon)
  end

  def setFull
    @status_item.setImage(@app_full_icon)
    @status_item.setAlternateImage(@app_full_alter_icon)
  end

  def setEmpty
    @status_item.setImage(@app_empty_icon)
    @status_item.setAlternateImage(@app_empty_alter_icon)
  end

end
