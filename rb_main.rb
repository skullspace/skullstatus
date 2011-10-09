# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework 'Cocoa'
framework 'Growl'
require 'time'
require 'net/https'

# Loading all the Ruby project files.
main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation

# try to load Security bs file on SnowLeopard, Lion 10.7 has version number 1138
load_bridge_support_file "#{dir_path}/BridgeSupport/Security.bridgesupport" if NSAppKitVersionNumber < 1138

Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
  if path != main
    require(path)
  end
end

def NSLocalizedString(key)
  NSBundle.mainBundle.localizedStringForKey(key, value:'', table:nil)
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
