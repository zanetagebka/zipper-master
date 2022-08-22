class AttachmentsController < ApplicationController
  def new
    @attachment = Attachment.new
  end

  def create
    return redirect_to new_attachment_path, notice: "File cannot be blank" if attachment_params.nil?

    @attachment = Attachment.new(attachment_params.to_unsafe_h)
    service = AttachmentZipper.new(@attachment, params[:attachment][:file].tempfile)
    buffer = service.call
    buffer.rewind
    @attachment.file.attach(io: StringIO.new(buffer.read),
                            filename: "#{@attachment.file.filename.to_s}.zip",
                            content_type: @attachment.file.content_type)

    resolve_save(@attachment, service.get_password)
  end

  def index
    @attachments = Attachment.all
  end

  private

  def attachment_params
    params[:attachment]
  end

  def resolve_save(attachment, password)
    if attachment.save
      redirect_to root_path, notice: "Your password is: #{password}"
    else
      render :new
    end
  end
end
