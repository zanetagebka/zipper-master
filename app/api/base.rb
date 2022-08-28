class Base < Grape::API
  mount Entities::Attachments
  mount Entities::Users
end
