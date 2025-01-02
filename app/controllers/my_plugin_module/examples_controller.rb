# app/jobs/indexnow_batch_ping.rb
module Jobs
  class IndexnowBatchPing < ::Jobs::Base
    def execute(args)
      # Fetch topics created in the last 30 days (you can modify the logic as needed)
      topics = Topic.where("created_at > ?", 30.days.ago).limit(100)
      
      topics.each do |topic|
        # Construct the URL for each topic
        url = "#{Discourse.base_url}/t/#{topic.slug}/#{topic.id}"
        
        # Log the URL being pinged
        Rails.logger.info("[IndexNow Plugin] Pinging URL: #{url}")
        
        # Call the ping method to notify IndexNow
        IndexNowPlugin.ping_indexnow(url)
      end
    end
  end
end
