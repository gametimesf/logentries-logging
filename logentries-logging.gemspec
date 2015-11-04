Gem::Specification.new do |s|
  s.name = "logentries-logging"
  s.version = "0.0.3"

  s.authors = ["Eric Nicholas"]
  s.require_paths = ["lib"]
  s.date = "2015-08-20"
  s.description = "Appender for logging to logentries with logging gem"
  s.email = "eric@gametime.co"
  s.files = [
    "LICENSE",
    "logentries-logging.gemspec",
    "lib/logging/appenders/logentries_logging.rb",
    "lib/logging/plugins/logentries_logging.rb",
  ]
  s.homepage = "http://github.com/gametimesf/logentries-logging"
  s.summary = "appender for logging to logentries"

end
