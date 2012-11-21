class SessionsController < ApplicationController
  def new
  end
  def create
    @user = User.authentication(params[:username],params[:password])
    if @user
      if not @user.oacode 
        flash[:notice] = "该用户未通过认证，请与管理员联系！"
        redirect_to new_session_path
      else
        a= ActiveRecord::Base.connection.select_all "select status from oadb.system_users where fnumber = '#{@user.oacode}'"
        u = a.first
        if  u["status"] == '1'
          session[:user_id]= @user.id
          flash[:notice] = t("loginsuccess")
          redirect_to topics_path
        else
          flash[:notice] = "该OA用户已被禁用"
          redirect_to new_session_path
        end
      end
    else
      flash[:notice] = "登录失败，用户名密码错误"
      redirect_to new_session_path
    end
  end
  
  def logout
    session[:user_id]= nil
    redirect_to new_session_path    
  end
end
