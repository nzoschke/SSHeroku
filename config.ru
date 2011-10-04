require "uri"
require "heroku/client"
require "./lib/heroku/client/routes"

run lambda { |env|
  @heroku = Heroku::Client.new(ENV["HEROKU_USER"], ENV["HEROKU_PASSWORD"])
  @app    = ENV["HEROKU_APP"]

  # get or create sshd ps
  unless @p = @heroku.ps(@app).detect { |p| p["process"] =~ /sshd/ && p["state"] == "up" }
    @p = @heroku.ps_run(@app, {:command => "sshd", :type => "sshd"})
    sleep 3
    puts "info: created process #{@p.inspect}"
  end

  # get or create route
  unless @r = @heroku.routes(@app).detect { |r| r["ps"] =~ /sshd/ }
    @r = @heroku.routes_create(@app)
    puts "info: created route #{@r.inspect}"
  end

  # attach route
  @heroku.route_detach(@app, @r["url"], @r["ps"]) if @r["ps"]
  @heroku.route_attach(@app, @r["url"], @p["process"])
  puts "info: attached route #{@r.inspect} to #{@p["process"]}"

  # introspect sshd ps
  logs = ""
  @heroku.read_logs(@app) { |chk| logs << chk }

  user = logs.scan(/user=([^ ]+)/).last[0]
  uri = URI.parse(@r["url"])

  [200, {"Content-Type" => "text/plain"}, ["-p #{uri.port} #{user}@#{uri.host}"]]
}