class IntentsController < ApplicationController
  def index
    intents = Intent.where(user_id: current_user_id).order(created_at: :desc)
    render json: intents, status: :ok
  end

  def create
    intent = Intent.new(intent_params)
    intent.user_id = current_user_id
    intent.status = "created" if intent.respond_to?(:status) && intent.status.blank?

    if intent.save
      render json: intent, status: :created
    else
      render json: intent.errors, status: :unprocessable_entity
    end
  end

  private

  def intent_params
    params.require(:intent).permit(:text)
  end

  def notify_planner(intent)
    # Pega o mesmo token que o cliente mandou
    token = request.headers["Authorization"]

    # Faz o POST pro planner (MVP usando Net::HTTP, sem gem extra)
    uri = URI("http://localhost:3003/plans/from_intent")

    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req["Authorization"] = token 

    req.body = { intent_id: intent.id, text: intent.text }.to_json
    http.request(req)
  rescue => e
    Rails.logger.error("notify_planner failed intent_id=#{intent.id} error=#{e.class} #{e.message}")
    # MVP: não quebra a criação da intent se o planner cair
  end
end
