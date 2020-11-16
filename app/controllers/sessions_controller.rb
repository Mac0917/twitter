class SessionsController < ApplicationController
    def create
        #binding.pry
        user = User.find_or_create_from_auth(request.env['omniauth.auth']) #twitterとの連携が取れるとデータが取得できる そのデータはrequest.env['omniauth.auth']にハッシュで入っている
        session[:user_id] = user.id
        redirect_to root_path
    end
    
    def destroy
        reset_session
        redirect_to root_path
    end      
end


#request.env['omniauth.auth']ではemailを取得できない！！！