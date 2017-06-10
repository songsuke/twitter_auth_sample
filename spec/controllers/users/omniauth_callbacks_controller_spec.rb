require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  context 'Twitter' do
    describe 'POST' do
      # set request env as twitter
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
          provider: 'twitter',
          uid: SecureRandom.hex(8),
          info: {
            email: 'user@example.com',
            name: 'user'
          }
        )
        @request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
        @request.env['devise.mapping'] = Devise.mappings[:user]
      end

      context 'when user already exists with Twitter auth' do
        let(:uid) { SecureRandom.hex(8) }
        let(:user) { create(:user,
                            provider: 'twitter',
                            uid: uid)
        }

        before do
          @request.env['omniauth.auth'].uid = uid
          post :twitter
        end
        it 'should not create user' do
          User.count == 1
        end
      end

      context 'when user already exists with email, and sign in with Twitter' do
        let(:uid) { SecureRandom.hex(8) }
        let(:user) { create(:user, password: SecureRandom.hex(8))}

        before do
          @request.env['omniauth.auth'].info.email = user.email
          @request.env['omniauth.auth'].uid = SecureRandom.hex(8)
          @request.env['omniauth.auth'].provider = 'twitter'
          post :twitter
        end

        it 'should not create user' do
          User.count == 1
        end

        it 'should update user uid' do
          expect(assigns(:user).uid).to eq(@request.env['omniauth.auth'].uid)
        end

        it 'should update user provider' do
          expect(assigns(:user).provider).to eq(@request.env['omniauth.auth'].provider)
        end
      end

      context 'when user does not exists' do
        let(:uid) { SecureRandom.hex(8) }

        before do
          @request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
        end

        context 'can create user' do
          let(:name) { Faker::Name.name }

          before do
            @request.env['omniauth.auth'].info.name = name
            post :twitter
          end

          it { expect(assigns(:user)).to_not be_new_record }
          it { expect(assigns(:user).name).to eq(name) }
        end

        context 'cannot create user when uid is not provided' do
          before do
            @request.env['omniauth.auth'].uid = nil
            post :twitter
          end

          it { expect(assigns(:user)).to be_new_record }
          it { expect(assigns(:user)).to_not be_valid }
        end
      end
    end
  end
end
