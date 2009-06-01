file project_name + ".rb" do 
  %{
module Rack
  class #{project_name}

    def initialize(app)
      @app = app
    end

    def call(env)
      [200, {'Content-Type' => 'text/html', 'Content-Length' => 100}, ['Hello World']]
    end
  end
end
}.strip
end

