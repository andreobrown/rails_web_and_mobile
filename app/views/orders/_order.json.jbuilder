json.extract! order, :id, :item, :quantity, :status, :created_at, :updated_at
json.url order_url(order, format: :json)
