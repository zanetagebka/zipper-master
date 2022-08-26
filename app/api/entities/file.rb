module Entities
  class File < Grape::Entity
    expose :filename
    expose :byte_size
    expose :created_at
  end
end
