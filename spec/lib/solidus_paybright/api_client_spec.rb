require "spec_helper"

describe SolidusPaybright::ApiClient do
  let(:base_url) { "https://sandbox.api.paybright.com/api" }

  subject { described_class.new("api-key", "api-token", base_url) }

  describe "#new" do
    it "requires the api_key, api_token and base_url parameter" do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new("api-key") }.to raise_error(ArgumentError)
      expect { described_class.new("api-key", "api-token") }.to raise_error(ArgumentError)
      expect { subject }.to_not raise_error
    end
  end

  describe "#void!" do
    let(:request_url) { "#{base_url}/orders/1234/void/" }
    let(:correct_signature) { "678d2aea7359043ac17ff0b5ecf9029c63039738d71ea051b935aaadeea96d47" }

    it "sends the correct request to the API" do
      expect(SecureRandom).to receive(:hex).and_return("nonce")
      expect(Typhoeus).to receive(:post).with(
        request_url,
        body: "",
        headers: {
          "Authorization" => "amx api-key:#{correct_signature}:nonce"
        }
      ).and_return(
        Typhoeus::Response.new(code: 200, body: '{"message": "success"}')
      )

      subject.void!("1234")
    end

    it "returns true on successfull response" do
      Typhoeus.stub(request_url) do
        Typhoeus::Response.new(code: 200, body: '{"message": "success"}')
      end

      expect(subject.void!("1234")).to be true
    end

    it "returns false on unsuccessfull response" do
      Typhoeus.stub(request_url) do
        Typhoeus::Response.new(code: 200, body: '{"message": "failed"}')
      end

      expect(subject.void!("1234")).to be false
    end

    it "returns false on error status code" do
      Typhoeus.stub(request_url) do
        Typhoeus::Response.new(code: 401, body: '')
      end

      expect(subject.void!("1234")).to be false
    end
  end

  describe "#refund!" do
    let(:request_url) { "#{base_url}/orders/1234/refund/" }
    let(:correct_signature) { "772bc0c8ecfaf4fe91b5b8d3b382bb4b8f804602392c71475397ba0b4737ef92" }

    it "sends the correct request to the API" do
      expect(SecureRandom).to receive(:hex).and_return("nonce")
      expect(Typhoeus).to receive(:post).with(
        request_url,
        body: "{\"amount\": 10.0}",
        headers: {
          "Authorization" => "amx api-key:#{correct_signature}:nonce",
          "Content-Type" => "application/json"
        }
      ).and_return(
        Typhoeus::Response.new(code: 200, body: '{"message": "success"}')
      )

      subject.refund!("1234", "10.0")
    end

    it "returns true on successfull response" do
      Typhoeus.stub(request_url) do
        Typhoeus::Response.new(code: 200, body: '{"message": "success"}')
      end

      expect(subject.refund!("1234", "10.0")).to be true
    end

    it "returns false on unsuccessfull response" do
      Typhoeus.stub(request_url) do
        Typhoeus::Response.new(code: 200, body: '{"message": "failed"}')
      end

      expect(subject.refund!("1234", "10.0")).to be false
    end

    it "returns false on error status code" do
      Typhoeus.stub(request_url) do
        Typhoeus::Response.new(code: 401, body: '')
      end

      expect(subject.refund!("1234", "10.0")).to be false
    end
  end
end
