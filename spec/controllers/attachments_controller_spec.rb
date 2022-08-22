require 'rails_helper'

RSpec.describe AttachmentsController do
  let(:file) { fixture_file_upload(Rails.root.join('spec/file_fixtures/image_test.png'), 'image/png') }

  it 'can go to #index' do
    get :index
    expect(response).to have_http_status(:success)
  end

  it 'empty params will not create attachment' do
    expect { post :create, params: { } }.not_to change(Attachment, :count)
  end

  it 'creates attachment and redirect to index with flash' do
    expect {
      post :create, params: { attachment: { file: file } }
    }.to change(Attachment, :count).by(1)
    expect(response).to redirect_to root_path
    expect(flash[:notice]).not_to be_nil
  end

  before do
    allow(SecureRandom).to receive(:hex).with(8).and_return('lalala')
  end

  it 'display password on flash' do
    post :create, params: { attachment: { file: file } }

    expect(flash[:notice]).to include("Your password is: lalala")
  end
end
