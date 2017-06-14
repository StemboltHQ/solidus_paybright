FactoryGirl.define do
  factory :paybright_payment_method, class: Spree::PaymentMethod::Paybright do
    name "Paybright"
  end

  factory :paybright_payment, class: Spree::Payment do
    association(:payment_method, factory: :paybright_payment_method)
    order
  end
end
