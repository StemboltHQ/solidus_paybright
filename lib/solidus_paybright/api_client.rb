require "typhoeus"
require "securerandom"
require "digest"
require "cgi"

module SolidusPaybright
  class ApiClient
    # @param api_key [String] The account Api key
    # @param api_token [String] The account secret Api token
    # @param base_url [String] The API base endpoint
    def initialize(api_key, api_token, base_url)
      @api_key = api_key
      @api_token = api_token
      @base_url = base_url
    end

    # This cancels an authorized order. For example, when a user decides to
    # cancel their order before it's fulfilled. Once a loan is voided, it is
    # permanently canceled and cannot be reauthorized.
    #
    # @param paybright_order_id [String] The Paybright order reference
    # @return [Boolean] The successfulness of the void operation
    def void!(paybright_order_id)
      uri = "#{@base_url}/orders/#{paybright_order_id}/void/"
      body = ""
      nonce = SecureRandom.hex

      response = Typhoeus.post(
        uri,
        body: body,
        headers: {
          "Authorization" => auth_header_for(nonce, body, uri)
        }
      )

      handle_response(response)
    end

    # Refund some amount of refunds on an Paybright order.
    # Once a loan is fully refunded it cannot be reinstated.
    #
    # @param paybright_order_id [String] The Paybright order reference
    # @param amount [String] The amount to refund
    # @return [Boolean] The successfulness of the refund operation
    def refund!(paybright_order_id, amount)
      uri = "#{@base_url}/orders/#{paybright_order_id}/refund/"
      body = "{\"amount\": #{amount}}"
      nonce = SecureRandom.hex

      response = Typhoeus.post(
        uri,
        body: body,
        headers: {
          "Authorization" => auth_header_for(nonce, body, uri),
          "Content-Type" => "application/json"
        }
      )

      handle_response(response)
    end

    private

    def auth_header_for(nonce, body, uri)
      params = {
        "x_apikey" => @api_key,
        "x_nonce" => nonce,
        "x_requestbodyhash" => Digest::MD5.base64digest(body),
        "x_requesttype" => "POST",
        "x_requesturi" => CGI.escape(uri).downcase
      }

      signature = SolidusPaybright::SigningHelper.new(@api_token).params_signature(params)

      "amx #{@api_key}:#{signature}:#{nonce}"
    end

    def handle_response(response)
      return false if response.code != 200

      json = JSON.parse(response.body)
      json["message"].to_s.casecmp("success").zero?
    end
  end
end
