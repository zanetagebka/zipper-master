require 'rails_helper'

RSpec.describe AttachmentZipper do
  let(:file) { fixture_file_upload(Rails.root.join('spec/file_fixtures/image_test.png'), 'image/png') }
  let(:params) { { file: file } }
  let(:tempfile) { Tempfile.new('lala') }

  it '#call write to zip file' do
    attachment = Attachment.new(params)

    service = AttachmentZipper.new(attachment, tempfile)
    expect(service.call).to be_kind_of(StringIO)
  end
end
