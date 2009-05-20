module Beet
  class Executor
    attr_reader :root
    attr_writer :logger

    def initialize(template, root = '') # :nodoc:
      @root = File.expand_path(File.directory?(root) ? root : File.join(Dir.pwd, root))
      log 'applying', "template: #{template}"
      load_template(template)
      log 'applied', "#{template}"
    end

    def load_template(template)
      begin
        code = open(template).read
        in_root { self.instance_eval(code) }
      rescue LoadError, Errno::ENOENT => e
        raise "The template [#{template}] could not be loaded. Error: #{e}"
      end
    end

  end
end
