module ApplicationHelper

#  def current_user
#    current_user ||= User.find(session[:user_id]) if session[:user_id]
#  end
 
 def controller_stylesheet_link_tag
    case controller_name
    when "users","home", "topics", "pages", "search", "sites", "notifications", "notes"
      stylesheet_link_tag controller_name
    when "replies"
      stylesheet_link_tag "topics"
    end
  end

  def controller_javascript_include_tag
    case controller_name
    when "pages","topics","sites", "notifications", "notes"
      javascript_include_tag controller_name
    when "replies"
      javascript_include_tag "topics"
    end
  end
  
  def user_avatar_width_size(size)
    case size
      when :normal then 48
      when :small then 16
      when :large then 64
      when :big   then 120
      else size
    end
  end

  def admin?(user= nil)
    user ||= current_user
    user.try(:admin?)
  end
 
  def owner?(item)
    #return false if item.blank? or current_user.blank?
    item.user_id == current_user.id
  end 
  def getavatar(user,size=:normal)
    width = user_avatar_width_size(size)
    if user.avatar?
      img = image_tag(user.avatar.url(size),:style => "width:#{width}px;height:#{width}px;")
    else
      if size == :normal 
        img_src = asset_path("avatar/t"+(user.id % 9 ).to_s+".jpg")
      else
        img_src =  asset_path ("avatar/avatar_#{size}.png")
      end
      img = image_tag(img_src,:alt => user.id ,:style => "width:#{width}px;height:#{width}px;")  
    end
  end
  
  def mark_required(object,attribute)
    "*" if object.class.validators_on(attribute).map(&:class).include? ActiveModel::Validations::PresenceValidator
    
  end  
end
