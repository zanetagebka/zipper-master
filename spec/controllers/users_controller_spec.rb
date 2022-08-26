require 'rails_helper'

RSpec.describe Devise::RegistrationsController, type: :request do
  context 'API POST' do
    subject { post '/api/users/register', params: params }
    let(:params) { { user: { email: 'random@example.com', password: 'testtest' } } }

    it 'creates user' do
      expect{ subject }.to change { User.count }.by(1)
    end
  end
end
