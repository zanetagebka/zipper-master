require 'rails_helper'

RSpec.describe AttachmentsController do
  render_views
  let(:file) { fixture_file_upload(Rails.root.join('spec/file_fixtures/image_test.png'), 'image/png') }
  let!(:user) { User.create!(username: 'something', email: 'test@example.com', password: 'testtest') }
  let!(:second_user) { User.create!(username: 'laal', email: 'example@example.com', password: 'testtest') }

  context 'logged in user' do
    before(:each) do
      sign_in user
    end

    it 'can go to #index' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'empty params will not create attachment' do
      expect { post :create, params: {} }.not_to change(Attachment, :count)
    end

    it 'creates attachment and redirect to index with flash' do
      expect {
        post :create, params: { attachment: { file: file } }
      }.to change(Attachment, :count).by(1)
      expect(response).to redirect_to root_path
      expect(flash[:notice]).not_to be_nil
    end

    it 'can see only own attachments' do
      attachment = Attachment.new(user: user)
      attachment.file.attach(io: File.open('spec/file_fixtures/image_test.png'), filename: 'some_name.png', content_type: 'image/png')
      attachment.save!
      second_attachment = Attachment.new(user: second_user)
      second_attachment.file.attach(io: File.open('spec/file_fixtures/image_test.png'), filename: 'test_name.png', content_type: 'image/png')
      second_attachment.save!
      get :index
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

RSpec.describe AttachmentsController, type: :request do
  context 'API POST successful' do
    subject { post '/api/attachments', params: params }
    let(:file) { fixture_file_upload(Rails.root.join('spec/file_fixtures/image_test.png'), 'image/png') }
    let(:user) { User.create(email: 'example@test.com', password: 'testtest') }
    let(:params) { { attachment: { file: file } } }

    before(:each) do
      allow_any_instance_of(User).to receive(:current_user).and_return(user)
    end

    it 'valid request' do
      subject
      expect(response).to have_http_status :created
    end

    it 'returns a JSON response' do
      subject

      body = JSON.parse(response.body)
      expect(body).to include('attachment')
      file = body['attachment']['file']
      expect(file).to include("filename" => "image_test.png")
    end

    it 'creates an attachment' do
      expect { subject }.to change { Attachment.count }.by(1)
    end

    it 'creates a blob' do
      expect { subject }.to change { ActiveStorage::Blob.count }.by(1)
    end
  end

  context 'API POST unsuccessful' do
    subject { post '/api/attachments', params: params }
    let(:params) { { attachment: { file: nil } } }

    it 'returns a JSON response' do
      subject
      expect(JSON.parse(response.body)).to eql(
                                             'attachment' => { 'file' => nil }
                                           )
    end

    it 'does not create a attachment' do
      expect { subject }.not_to change { Attachment.count }.from(0)
    end

    it 'does not create a blob' do
      expect { subject }.not_to change { ActiveStorage::Blob.count }.from(0)
    end
  end

  context 'API GET' do
    let!(:user) { User.create!(username: 'something', email: 'test@example.com', password: 'testtest') }

    before(:each) do
      allow(Time).to receive(:now).and_return(Time.new(2020, 10, 10, 10))
    end

    it 'get attachments' do
      attachment = Attachment.new(user: user)
      attachment.file.attach(io: File.open('spec/file_fixtures/image_test.png'), filename: 'some_name.png', content_type: 'image/png')
      attachment.save!

      get '/api/attachments'
      parsed_body = JSON.parse(response.body)
      expect(parsed_body)
        .to eq(
              [{
                 "created_at" => "2020-10-10T08:00:00.000Z",
                 "file" => {
                   "byte_size" => 0,
                   "created_at" => "2020-10-10T08:00:00.000Z",
                   "filename" => "some_name.png"
                 },
                 "id" => 1,
                 "user_id" => 1 }
              ]
            )
    end
  end
end
