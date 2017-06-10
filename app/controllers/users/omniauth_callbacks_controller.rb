module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def twitter
      data = request.env['omniauth.auth'].except('extra')
      @user = User.from_omniauth(data)

      if @user.persisted?
        sign_in_and_redirect(@user)
      else
        session['devise.omniauth'] = data
        redirect_to root_path
      end
    end

    def failure
      redirect_to root_path
    end
  end
end
