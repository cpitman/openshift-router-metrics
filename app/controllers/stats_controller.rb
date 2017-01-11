require 'csv'

class StatsController < ApplicationController
  before_action :require_login

  def index
    response = JSON.parse access_token.get('/oapi/v1/projects').body
    projects = response['items'].collect { |item| item['metadata']['name'] }

    @routes = projects.collect_concat { |project|
      response = JSON.parse access_token.get("/oapi/v1/namespaces/#{project}/routes").body
      response['items'].collect { |item| {route: item['metadata']['name'], project: item['metadata']['namespace'] } }
    }.to_set

    response = JSON.parse service_account.get('/api/v1/namespaces/default/pods', {labelSelector: 'router=router'}).body
    routers = response['items'].collect { |item| 
      {
        ip: item['status']['podIP'], 
        name: item['metadata']['name'], 
        password: item['spec']['containers'][0]['env'].find { |entry| entry['name'] == 'STATS_PASSWORD' }['value'], 
        username: item['spec']['containers'][0]['env'].find { |entry| entry['name'] == 'STATS_USERNAME' }['value'], 
        port: item['spec']['containers'][0]['env'].find { |entry| entry['name'] == 'STATS_PORT' }['value'] 
      }
    }

    router_stats = nil
    routers.each { |router| 
      item = get_router_stats(router[:ip], router[:port], router[:username], router[:password])
      item['router'] = router[:name]
      if router_stats.nil?
        router_stats = item.by_col_or_row
      else
        item.each { |row| router_stats.push row }
      end
    }

    router_stats.delete_if { |route| !@routes.include?({route: route['route'], project: route['project']} ) }


    if params.include? :csv
      render plain: router_stats
    end

    @route_stats = router_stats.group_by { |route| {route: route['route'], project: route['project']} }
  end

  def get_router_stats(ip, port, username, password)
    router_conn = Faraday.new("http://#{ip}:#{port}/") 
    router_conn.basic_auth username, password

    be_regex = /^[^_]*_[^_]*_([^_]*)_([^_]*)$/

    response = CSV.parse router_conn.get('/;csv').body, headers: true
    response.delete_if { |row| be_regex.match(row['# pxname']).nil? }
    response['project'] = response['# pxname'].collect{ |pxname| be_regex.match(pxname).captures[0] }	
    response['route'] = response['# pxname'].collect{ |pxname| be_regex.match(pxname).captures[1] }
#    response.delete('# pxname')
    response	
  end

  def get_row_style(row)
    return 'backend' if row['type'] == '1'
    return '' if row['type'] != '2'

    if row['status'] == 'UP'
      return 'active4' if row['act'] == '1'
      return 'backup4' if row['bck'] == '1'
    end

    #Going Down
    if row['status'] == 'NOLB '
      return 'active2' if row['act'] == '1'
      return 'backup2' if row['bck'] == '1'
    end

    #Going Up
    if row['status'] == 'DOWN '
      return 'active3' if row['act'] == '1'
      return 'backup3' if row['bck'] == '1'
    end

    return 'active9' if row['status'] == 'no check'

    return 'active0' if row['status'] == 'DOWN' || row['status'] == 'DOWN (agent)'
    return 'maintain' if row['status'] == 'MAINT'
  end

  helper_method :get_row_style
end
