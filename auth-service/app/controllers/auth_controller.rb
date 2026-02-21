class AuthController < ApplicationController
  skip_before_action :authorize_request, only: %i[login signup]

  def signup
    user = User.create!(email: params[:email], password: params[:password])
    token = JsonWebToken.encode(user_id: user.id)
    render json: { token: token, user: { id: user.id, email: user.email } }, status: :created
  end

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: { id: user.id, email: user.email } }, status: :ok
    else
      render json: { error: 'E-mail ou senha inválidos' }, status: :unauthorized
    end
  end

  def me
    render json: { id: current_user.id, email: current_user.email }, status: :ok
  end
end
