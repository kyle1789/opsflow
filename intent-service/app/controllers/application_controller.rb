class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_user_id

  private

  def authorize_request
    token = extract_bearer_token
    return render_unauthorized("Token ausente") if token.nil?

    decoded = JsonWebToken.decode(token)
    return render_unauthorized("Token expirado") if decoded == :expired
    return render_unauthorized("Token inválido") if decoded.nil?

    @current_user_id = decoded[:user_id]
    return render_unauthorized("Token sem user_id") if @current_user_id.nil?
  end

  def extract_bearer_token
    header = request.headers["Authorization"]
    return nil if header.blank?

    scheme, token = header.split(" ", 2)
    return nil unless scheme == "Bearer" && token.present?

    token
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end
end
