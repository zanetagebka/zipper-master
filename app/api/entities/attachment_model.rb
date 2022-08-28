module Entities
  class AttachmentModel < Grape::Entity
    expose :id
    expose :user_id
    expose :created_at
    expose :file, with: Entities::File
  end
end
