class ApplicationController < ActionController::Base
  before_filter :load_nodes,:load_count
  protect_from_forgery
  helper_method :current_user
    private
  def current_user
    current_user ||= User.find(session[:user_id]) if session[:user_id]
  end 
  def load_nodes
      @nodes= Node.all
  end

  def load_count
    @user_count = User.count
    @topic_count = Topic.count
    @reply_count = Reply.count
  end
  
  def check_login
    if current_user.nil?
        flash[:notice] = "需要登录才能访问！"
        redirect_to new_session_path
    end
  end
end
