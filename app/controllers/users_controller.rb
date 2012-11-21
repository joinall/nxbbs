class UsersController < ApplicationController
  
  before_filter :check_login, :only=>[:index,:show]
  def index
    @newusers = User.where("oacode is not null").order("created_at DESC").paginate(:page=> params[:page],:per_page => 60)
    @unusers = User.where(:oacode => nil).order("created_at DESC")   
  end

  def new
    @user= User.new
  end
  
  def create
    #用户名是否被注册
   # euser= User.find_by_username(params[:user][:username])
    
   @user= User.new(params[:user]) 
    if @user.save 
      #session[:user_id]= @user.id
      flash[:notice] = "注册成功，登录后可访问论坛。"
      redirect_to new_session_path
    else
      render :action => "new"    
    end
  end    

  def show
    @user = User.find(params[:id])
    @topics = @user.topics.order("created_at desc").includes(:node).limit(10)
    @replies = @user.replies.order("created_at desc").includes(:topic).limit(10)
  end
  
  def edit
    @user=current_user
  end

  def update

    @user = current_user
    if params[:user][:netname] != @user.netname
     @user.netname = params[:user][:netname] 
    end
    if params[:user][:avatar] 
       @user.avatar = params[:user][:avatar]
    end
    if @user.save   
      #@user.update_attribute("netname",params[:user][:netname])
      flash[:notice]  = "用户信息修改成功！"
      redirect_to user_path(@user)
    else
      render :action =>"edit"
    end
  end


# 修改密码
  def changepass
    @user = current_user    
    if  params[:newpass] == params[:newpass_confirm] 
      s = User.authentication(current_user.username,params[:oldpass]) 
      if s 
        @user.password = params[:newpass]
        if @user.save
          flash[:notice] = "密码修改成功!"
          redirect_to user_path(@user)
        else
          flash[:notice] = "修改密码失败!"
          redirect_to edit_user_path(@user)
        end
      else
        flash[:notice] = "原密码错误!"
        redirect_to  edit_user_path(@user) 
      end
    else
      flash[:notice] = "输入的两次新密码不一致！"
      redirect_to edit_user_path(@user)
    end
  end       
end
