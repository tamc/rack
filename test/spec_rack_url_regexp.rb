require 'test/spec'

require 'rack/url_regexp'
require 'rack/mock'

context "Rack::URLRegexp" do
  specify "dispatches paths correctly when fed a hash (so that regexps matched longest first)" do
    app = (0..5).to_a.map do |index|
        lambda { |env|
          [200, {'Content-Type' => 'text/plain'}, ["app#{index}"]]
        }
    end
    
    map = Rack::URLRegexp.new({
      %r{bar} => app[0],
      %r{/foo} => app[1],
      %r{/foo/bar} => app[2],
      %r{/hello-(world|ruby)} => app[3],
      %r{/(.*?)\.txt} => app[4]
    })

    res = Rack::MockRequest.new(map).get("/")
    res.should.be.not_found

    res = Rack::MockRequest.new(map).get("/qux")
    res.should.be.not_found

    res = Rack::MockRequest.new(map).get("/bar")
    res.should.be.ok
    res.body.should.equal 'app0'

    res = Rack::MockRequest.new(map).get("/fizz/bar")
    res.should.be.ok
    res.body.should.equal 'app0'

    res = Rack::MockRequest.new(map).get("/foo")
    res.should.be.ok
    res.body.should.equal 'app1'

    res = Rack::MockRequest.new(map).get("/foo/")
    res.should.be.ok
    res.body.should.equal 'app1'

    res = Rack::MockRequest.new(map).get("/foo/bar")
    res.should.be.ok
    res.body.should.equal 'app2'

    res = Rack::MockRequest.new(map).get("/foo/bar/")
    res.should.be.ok
    res.body.should.equal 'app2'

    res = Rack::MockRequest.new(map).get("/hello-world")
    res.should.be.ok
    res.body.should.equal 'app3'

    res = Rack::MockRequest.new(map).get("/hello-ruby")
    res.should.be.ok
    res.body.should.equal 'app3'

    res = Rack::MockRequest.new(map).get("/hello-python")
    res.should.be.not_found
    
    res = Rack::MockRequest.new(map).get("/bar.txt")
    res.should.be.ok
    res.body.should.equal 'app4'
  end

  specify "dispatches paths correctly when fed an array (so that regexps matched in ordergit)" do
    app = (0..5).to_a.map do |index|
        lambda { |env|
          [200, {'Content-Type' => 'text/plain'}, ["app#{index}"]]
        }
    end
    
    map = Rack::URLRegexp.new([
     [%r{bar}, app[0]],
     [%r{/foo},  app[1]],
     [%r{/foo/bar},  app[2]],
     [%r{/hello-(world|ruby)},  app[3]],
     [%r{/(.*?)\.txt}, app[4]]
    ])

    res = Rack::MockRequest.new(map).get("/")
    res.should.be.not_found

    res = Rack::MockRequest.new(map).get("/qux")
    res.should.be.not_found

    res = Rack::MockRequest.new(map).get("/bar")
    res.should.be.ok
    res.body.should.equal 'app0'

    res = Rack::MockRequest.new(map).get("/fizz/bar")
    res.should.be.ok
    res.body.should.equal 'app0'

    res = Rack::MockRequest.new(map).get("/foo")
    res.should.be.ok
    res.body.should.equal 'app1'

    res = Rack::MockRequest.new(map).get("/foo/")
    res.should.be.ok
    res.body.should.equal 'app1'

    res = Rack::MockRequest.new(map).get("/foo/bar")
    res.should.be.ok
    res.body.should.equal 'app0'

    res = Rack::MockRequest.new(map).get("/foo/bar/")
    res.should.be.ok
    res.body.should.equal 'app0'

    res = Rack::MockRequest.new(map).get("/hello-world")
    res.should.be.ok
    res.body.should.equal 'app3'

    res = Rack::MockRequest.new(map).get("/hello-ruby")
    res.should.be.ok
    res.body.should.equal 'app3'

    res = Rack::MockRequest.new(map).get("/hello-python")
    res.should.be.not_found
    
    res = Rack::MockRequest.new(map).get("/bar.txt")
    res.should.be.ok
    res.body.should.equal 'app0'
  end

end
