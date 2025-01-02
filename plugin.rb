# frozen_string_literal: true

# Plugin Metadata
# name: indexnow-plugin
# about: Notify search engines using IndexNow protocol
# version: 0.1
# authors: Your Name
# url: https://github.com/your-repo/indexnow-plugin

enabled_site_setting :indexnow_enabled

after_initialize do
  # Add your customizations here
  
  module ::IndexNowPlugin
    class Engine < ::Rails::Engine
      engine_name "indexnow_plugin"
      isolate_namespace IndexNowPlugin
    end
  end

  # Serve the IndexNow key file
  Discourse::Application.routes.append do
    get "/indexnow-key/:key" => "index_now_plugin#indexnow_key"
  end

  # Controller to handle IndexNow key
  class ::IndexNowPlugin::IndexNowController < ApplicationController
    def indexnow_key
      render plain: SiteSetting.indexnow_key, content_type: "text/plain"
    end
  end

  # Trigger IndexNow ping when a new topic is created or updated
  Topic.register_topic_post_processer(:indexnow_notify) do |topic, _post|
    if SiteSetting.indexnow_enabled
      url = "#{Discourse.base_url}/t/#{topic.slug}/#{topic.id}"
      ping_indexnow(url)
    end
  end

  # Method to send IndexNow pings
  def ping_indexnow(url)
    require "net/http"
    require "uri"

    indexnow_url = "https://www.bing.com/indexnow"
    payload = { host: URI.parse(url).host, key: SiteSetting.indexnow_key, urlList: [url] }
    uri = URI.parse(indexnow_url)

    Net::HTTP.post(
      uri,
      payload.to_json,
      "Content-Type" => "application/json"
    )
  end
end
