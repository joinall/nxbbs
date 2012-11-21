class TopicsController < ApplicationController
  
  before_filter :check_login
  def index
    @topics = Topic.select("id,title,node_id,user_id,last_reply_user_id,last_replytime,replycount,updated_at,created_at").order("last_replytime desc").includes(:user).paginate(:page=> params[:page],:per_page => 10)
  end
  
  def show
    @topic = Topic.find(params[:id])
    Topic.record_timestamps = false
    @topic.readtimes += 1
    @topic.save
    Topic.record_timestamps = true 
    @replies = @topic.replies.includes(:user).order("created_at")
    @reply_counter = 1 
    @nreply = Reply.new
  end
  def new
    @topic= Topic.new
  end

  def create
    pt = params[:topic]
    @topic =Topic.new(pt)
    @topic.user_id = current_user.id
    @topic.last_replytime = Time.now
    if @topic.save
      redirect_to topic_path(@topic)
    else
      render :action => "new"
    end

  end
  
  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    pt = params[:topic]
    @topic.node_id =  pt[:node_id]
    @topic.title = pt[:title]
    @topic.content = pt[:content]
    @topic.unreply_all = pt[:unreply_all]
    @topic.unreply_other = pt[:unreply_other]
  
    if @topic.save
      flash[:notice] =   t("topics.update_topic_success")
      redirect_to topic_path(@topic.id) 
    else
      render :action => "edit"
    end
  end

  def destroy
    #flash[:notice] = "暂时还没有实现删除帖子的功能！"
    #render :action => "show"
  end  
  def node
    @node = Node.find(params[:id])
    @topics = @node.topics.includes(:user)
   # @topics = @node.topics.last_actived.fields_for_list.includes(:user).paginate(:page => params[:page],:per_page => 15)
   # set_seo_meta("#{@node.name} &raquo; #{t("menu.topics")}","#{Setting.app_name}#{t("menu.topics")}#{@node.name}",@node.summary)
   # drop_breadcrumb("#{@node.name}")
    render :action => "index" #, :stream => true
  end

end
