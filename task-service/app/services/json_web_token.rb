class JsonWebToken
  ALGORITHM = "HS256".freeze

  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload = payload.dup
      payload[:exp] = exp.to_i
      JWT.encode(payload, secret_key, ALGORITHM)
    end

    def decode(token)
      decoded, _header = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::ExpiredSignature
      :expired
    rescue JWT::DecodeError
      nil
    end

    private

    def secret_key
      ENV.fetch("JWT_SECRET")
    end
  end
end
