class User < Sequel::Model

  def before_create
    self.salt = SecureRandom.hex
    self.api_key = SecureRandom.hex
    self.pem = OpenSSL::PKey::RSA.generate(2048).to_pem
  end

end
