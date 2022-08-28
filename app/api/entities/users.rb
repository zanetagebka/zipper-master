module Entities
  class Users < Grape::API
    format :json
    prefix :api

    resource :users do
      desc 'Login user'
      params do
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'User password'
      end

      post 'login' do
        email = params[:email]
        password = params[:password]

        if email.nil? || password.nil?
          error!({
                   error_code: 404, error_message: 'Invalid email or password'
                 },
                 401)
        else

        end
      end

      desc 'Register user'
      params do
        requires :user, type: Hash do
          requires :email, type: String, desc: 'User email'
          requires :password, type: String, desc: 'User password'
        end
      end

      post 'register' do
        user = User.new(email: params[:user][:email], password: params[:user][:password])
        if user.valid?
          user.save
        else
          error!({ error_code: 404 }, 401)
        end
      end
    end
  end
end
