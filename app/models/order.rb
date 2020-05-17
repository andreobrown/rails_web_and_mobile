class Order < ApplicationRecord
  belongs_to :customer
  enum status: { submitted: "submitted", ready: "ready", filled: "filled" }
end
