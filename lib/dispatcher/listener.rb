require 'rest_client'

class Listener

  def initialize(cfg, logger)
    @cfg = cfg
    @logger = logger
  end

  def listen(client)

    while line = client.gets
      data = line
      @logger.debug "incoming -> #{data}"
      next if line.reverse[0] == "#"
      parts = data.split(',')
      @logger.info "[#{parts[1]}] -> #{data}"
      client.close
      break
    end

    begin
      remote = TCPSocket.new @cfg['LIVEGTS_SERVER'], @cfg['LIVEGTS_PORT']
    rescue Errno::ECONNREFUSED
      @logger.error "Connection to LiveGTS server hosted at fleetservice.0-one.net on port 31200 was refused"
    end

    begin
      remote.send(data, 0)
    rescue Exception => e
      @logger.error "Failed to forward message to the LiveGTS server"
      @logger.error(e.message)
    end

    remote.close

    @cfg['GOWANE_DESTINATIONS'].each do |url|
      begin
        RestClient.post "http://#{url}", {data: data}
      rescue Exception => e
        @logger.error "An error occured while relaying to #{url}"
        @logger.error e.message
      end

    end

    @logger.debug "[#{Thread.current.to_s}] :: Forwarding complete"

  end

end