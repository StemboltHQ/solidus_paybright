require "spec_helper"

describe SolidusPaybright::SigningHelper do
  let(:key) { "iU44RWxeik" }
  let(:base_params) {
    {
      "x_test" => "true",
      "x_account_id" => "Z9s7Yt0Txsqbbx",
      "x_amount" => 89.99,
      "x_currency" => "USD",
      "x_gateway_reference" => "123",
      "x_reference" => "19783",
      "x_result" => "completed",
      "x_timestamp" => "2014-03-24T12:15:41Z"
    }
  }
  let(:correct_signature) { "49d3166063b4d881b50af0b4648c1244bfa9890a53ed6bce6d2386404b610777" }

  subject { described_class.new(key) }

  describe "#new" do
    it "requires the key param" do
      expect { described_class.new } .to raise_error(ArgumentError)
      expect { subject }.to_not raise_error
    end
  end

  describe "#params_signature" do
    it "returns the correct signature" do
      expect(subject.params_signature(base_params)).to eq(correct_signature)
    end

    it "ignores params not starting with 'x_'" do
      params = base_params.merge("some_other_param" => "value")
      expect(subject.params_signature(params)).to eq(correct_signature)
      expect(params["some_other_param"]).to be_present
    end

    it "ignores the x_signature param" do
      params = base_params.merge("x_signature" => "value")
      expect(subject.params_signature(params)).to eq(correct_signature)
    end
  end

  describe "#valid_params?" do
    it "returns true if the signed params are correct" do
      params = base_params.merge("x_signature" => correct_signature)
      expect(subject.valid_params?(params)).to be true
    end

    it "returns false if the signature is not correct" do
      params = base_params.merge("x_signature" => "wrongsignature")
      expect(subject.valid_params?(params)).to be false
    end

    it "returns false if some data was altered" do
      params = base_params.merge("x_signature" => correct_signature, "x_test" => "false")
      expect(subject.valid_params?(params)).to be false
    end

    it "returns false if the 'x_signature' param is missing" do
      expect(subject.valid_params?(base_params)).to be false
    end
  end
end
