require 'zip'

class AttachmentZipper
  def initialize(attachment, tempfile)
    @attachment = attachment
    @password = SecureRandom.hex(8)
    @tempfile = tempfile
  end

  def call
    zip_attachment
  end

  def get_password
    @password
  end

  private

  def zip_attachment
    Zip::OutputStream.write_buffer(::StringIO.new(''), Zip::TraditionalEncrypter.new(@password)) do |o|
      o.put_next_entry(@attachment.file.blob.filename)
      o.write File.open(@tempfile).read
    end
  end
end
