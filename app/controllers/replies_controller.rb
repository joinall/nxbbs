class RepliesController < ApplicationController
  
  before_filter :find_topic
  def create
    @reply = @topic.replies.build(params[:reply])
    @reply.user_id = current_user.id
    if @reply.save
      redirect_to topic_path(@topic)
    else
      redirect_to topic_path(@topic)
    end
  end
  
  def edit
    @reply = Reply.find(params[:id])
  end

  def update
    @reply = Reply.find(params[:id])
#    @reply.content =  params[:reply][:content]

    if @reply.update_attributes(params[:reply])
      flash[:notice] = "回帖更新成功."
      redirect_to topic_path(@reply.topic_id)
    else
      render :action => "edit"
    end

  end
 
  def find_topic
    @topic = Topic.find(params[:topic_id])
  end

end

