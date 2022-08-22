require 'rails_helper'

RSpec.describe AttachmentsController do
  render_views
  let(:file) { fixture_file_upload(Rails.root.join('spec/file_fixtures/image_test.png'), 'image/png') }
  let!(:user) { User.create!(username: 'something', email: 'test@example.com', password: 'testtest') }
  let!(:second_user)  { User.create!(username: 'laal', email: 'example@example.com', password: 'testtest') }

  context 'logged in user' do
    let(:attachment) { Attachment.create!(user: user) }
    let!(:second_attachment) { Attachment.create!(user: second_user) }
    let!(:first_attachment_file) {
      attachment.file.attach(io: File.open('spec/file_fixtures/image_test.png'), filename: 'some_name.png', content_type: 'image/png')
    }
    let!(:second_attachment_file) {
      second_attachment.file.attach(io: File.open('spec/file_fixtures/image_test.png'), filename: 'test_name.png', content_type: 'image/png')
    }

    before(:each) do
      sign_in user
    end

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

    it 'can see only own attachments' do
      get :index
      p second_attachment.file
      expect(response.body).to include('some_name.png')
      expect(response.body).not_to include('test_name.png')
    end

    before do
      allow(SecureRandom).to receive(:hex).with(8).and_return('lalala')
    end

    it 'display password on flash' do
      post :create, params: { attachment: { file: file } }

      expect(flash[:notice]).to include("Your password is: lalala")
    end
  end

  context 'not logged in user' do
    it 'can not go to #index' do
      get :index
      expect(response).to redirect_to new_user_session_path
    end
  end
end
