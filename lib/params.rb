require 'uri'

class URI::HTTP
  def set_params(param_hash)
    if self.query.nil?
      decoded_query = []
    else
      decoded_query = URI.decode_www_form(self.query)
    end
    decoded_query = (Hash[*(decoded_query.flatten)].merge(param_hash)).to_a

    encoded_query = URI.encode_www_form(decoded_query)
    self.query = encoded_query.empty? ? nil : encoded_query

    self
  end
end

