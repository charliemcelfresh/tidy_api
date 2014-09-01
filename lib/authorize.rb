class Authorize

  require 'openssl'
  require "base64"
  
  def initialize(request)
    @request = request
  end
  
  def authorized?
    return true if hmac_encoded_hash == env['hmac_encoded_hash']
    false
  end
  
  def message
    user.salt + @request
  end
  
  def user
    User.first
  end
  
  def hmac_encoded_hash
    Base64.encode64(OpenSSL::HMAC.digest('sha256', user.id_rsa, message))
  end

end