# frozen_string_literal: true

require "openssl"

module SolidusPaybright
  class SigningHelper
    SIGNATURE_PARAM_KEY = "x_signature"

    # @param hmac_key [String] The HMAC secret key used for signing
    def initialize(hmac_key)
      @hmac_key = hmac_key
    end

    # @param params [Hash] The parameters to be signed
    # @return [String] The signature of the parameters
    def params_signature(params)
      message = params.select do |key, _|
        key != SIGNATURE_PARAM_KEY && key.start_with?("x_")
      end.sort.join

      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), @hmac_key, message)
    end

    # @param params [Hash] The parameters to be validated, including the "x_signature" key
    # @return [Boolean] The validation result
    def valid_params?(params)
      expected_signature = params[SIGNATURE_PARAM_KEY].to_s
      signature = params_signature(params)

      expected_signature.casecmp(signature.downcase).zero?
    end
  end
end
