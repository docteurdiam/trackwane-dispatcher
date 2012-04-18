class Configuration

  def initialize(logger)
    @logger = logger
  end

  def parse(filename)
    @logger.info "Reading configuration from #{File.expand_path(filename)}"
    cfg = YAML.load_file(filename)
  end

end