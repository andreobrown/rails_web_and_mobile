class Order < ApplicationRecord
  enum status: { submitted: "submitted", ready: "ready", filled: "filled" }
end
