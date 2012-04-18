require 'uri'
require 'socket'
require 'net/http'
require 'dispatcher/configuration'
require 'dispatcher/listener'
require 'trollop'
require 'yell'
require 'active_support/all'

class Program

  def self.run

    opts = Trollop::options do
      opt :file, "Required configuration file", :type => String
    end

    Trollop::die :file, "must be provided" unless opts[:file]

    logger = Yell.new STDOUT

    logger.info "Running the Trackwane Dispatcher"

    cfg = Configuration.new(logger).parse(opts[:file])

    Thread.abort_on_exception = true
    server = TCPServer.open(cfg["TRACKER_PORT"])
    loop {
      Thread.start(server.accept) do |client|
        Listener.new(cfg, logger).listen(client)
      end
    }
  end

end
