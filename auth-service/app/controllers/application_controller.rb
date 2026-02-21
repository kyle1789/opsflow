class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_user

  private

  def authorize_request
    header = request.headers['Authorization']
    return render_unauthorized('Token ausente') if header.blank?

    scheme, token = header.split(' ', 2)
    return render_unauthorized('Token malformado') unless scheme == 'Bearer' && token.present?

    decoded = JsonWebToken.decode(token)
    return render_unauthorized('Token inválido ou expirado') if decoded.nil? || decoded == :expired

    @current_user = User.find(decoded[:user_id])
  rescue ActiveRecord::RecordNotFound
    render_unauthorized('Usuário não encontrado')
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end
end
