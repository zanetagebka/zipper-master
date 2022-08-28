module Entities
  class Attachments < Grape::API
    format :json
    prefix :api

    resource :attachments do
      desc 'Return list of attachments with files'
      get do
        entities = Attachment.all
        present entities, with: Entities::AttachmentModel
      end

      desc 'Return a specific attachment'
      route_param :id do
        get do
          entity = Attachment.find(params[:id])
          present entity, with: Entities::AttachmentModel
        end
      end

      desc 'Upload file'
      params do
        requires :attachment, type: Hash do
          requires :file, type: Rack::Multipart::UploadedFile, desc: "Image file."
        end
      end
      post do
        params
      end
    end
  end
end
