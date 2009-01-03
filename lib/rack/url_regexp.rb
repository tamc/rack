module Rack
  # Rack::URLRegexp takes a hash mapping regular expressions to apps.
  # The regular expression is checked against the path and if it 
  # matches, then it dispatches to the application
  #
  # Rack::URLRegexp.new(
  #   /.*/ => app1,
  #   /\.txt/ => app2
  # )
  #
  # It dispatches in such a way that the longest regular expressions are 
  # tried first. In the example above that means it would try /\.txt/ before
  # /.*/. If you don't want this to happen, use an array of arrays in the 
  # initialiser:
  #
  # Rack::URLRegexp.new([
  #   [/.*/, app1],
  #   [/\.txt/, => app2]
  # ])
  # 
  # It doesn't modify any of the variables passed to to the app
  #
  class URLRegexp
    def initialize(map)
      @mapping = case map
      when Hash; map.sort_by { |expression, app| -expression.inspect.size }
      when Array; map
      end
    end

    def call(env)
      path = env["PATH_INFO"].to_s.squeeze("/")
      @mapping.each do |expression, app|
          return app.call(env) if expression =~ path
      end
      [404, {"Content-Type" => "text/plain"}, ["Not Found: #{path}"]]
    end
  end
end

