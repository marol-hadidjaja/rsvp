json.array!(@invitees) do |invitee|
  json.extract! invitee, :id, :name, :relation, :number, :email, :address, :phone, :response, :arrival, :created_at, :updated_at
  json.url invitee_url(invitee, format: :json)
end
