class Heroku::Client
  def routes(app_name)
    json_decode(get("/apps/#{app_name}/routes").to_s)
  end

  def routes_create(app_name, proto=nil)
    query = (proto.nil? ? "" : "?proto=#{proto}")
    json_decode(post("/apps/#{app_name}/routes#{query}").to_s)
  end

  def route_attach(app_name, url, ps)
    put("/apps/#{app_name}/routes/attach", {"url" => URI.escape(url), "ps" => URI.escape(ps)})
  end

  def route_detach(app_name, url, ps)
    put("/apps/#{app_name}/routes/detach", {"url" => URI.escape(url), "ps" => URI.escape(ps)})
  end

  def route_destroy(app_name, url)
    delete("/apps/#{app_name}/routes?url=#{URI.escape(url)}", {})
  end
end