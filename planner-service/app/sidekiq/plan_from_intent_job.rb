require "net/http"
require "uri"
require "json"

class PlanFromIntentJob
  include Sidekiq::Worker
  sidekiq_options queue: :planning, retry: 10

  PROCESS_SERVICE_URL = ENV.fetch("PROCESS_SERVICE_URL", "http://localhost:3004").freeze
  TASK_SERVICE_URL = ENV.fetch("TASK_SERVICE_URL", "http://localhost:3005").freeze  

  def perform(intent_id, user_id, text, bearer_token = nil)
    Rails.logger.info("PLANNING intent_id=#{intent_id} user_id=#{user_id}")

    workflow = create_workflow(intent_id: intent_id, title: text, status: "planned", bearer_token: bearer_token)
    
    create_task(
      workflow_id: workflow["id"],
      title: "Planejamento inicial concluído",
      bearer_token: bearer_token
    )


    Rails.logger.info("WORKFLOW created id=#{workflow["id"]} intent_id=#{workflow["intent_id"]}")
  end
  
  def create_task(workflow_id:, title:, bearer_token:)
  uri = URI("#{TASK_SERVICE_URL}/tasks")
  http = Net::HTTP.new(uri.host, uri.port)

  req = Net::HTTP::Post.new(uri)
  req["Content-Type"] = "application/json"
  req["Authorization"] = bearer_token if bearer_token.present?

  req.body = { task: { workflow_id: workflow_id, title: title, status: "done" } }.to_json

  res = http.request(req)
  raise "task-service error status=#{res.code} body=#{res.body}" unless res.is_a?(Net::HTTPCreated)

  JSON.parse(res.body)
  end

  private

  def create_workflow(intent_id:, title:, status:, bearer_token:)
    uri = URI("#{PROCESS_SERVICE_URL}/workflows")
    http = Net::HTTP.new(uri.host, uri.port)

    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"

    if bearer_token.present?
      req["Authorization"] = bearer_token
    else
      # fallback pra debug: sem auth vai dar 401 
      Rails.logger.warn("No bearer_token provided to planner job")
    end

    req.body = { workflow: { intent_id: intent_id, title: title, status: status } }.to_json

    res = http.request(req)
    raise "process-service error status=#{res.code} body=#{res.body}" unless res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPCreated)

    JSON.parse(res.body)
  end
end