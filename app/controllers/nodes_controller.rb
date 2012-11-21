class NodesController < ApplicationController
  def show
    @nodes = Node.all
    @node =  Node.find(params[:id])
    @topics = @node.topics.order("last_replytime desc").paginate(:page=> params[:page],:per_page => 15)
  end
end

