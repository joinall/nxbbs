require 'digest/sha1'
class User < ActiveRecord::Base

  #确认密码验证 
  attr_accessor   :password, :password_confirmation,:oapass
  attr_accessible :password, :password_confirmation,:oapass,:avatar
  validates_confirmation_of :password,  :message => "两次输入的密码不一致!"
  
  attr_accessible :username,:netname,:oacode,:telephone,:truename,:isadmin
   
  #校验 不能为空
 # validates_presence_of :username, :netname,  :truename,:password , :on => "create"
  
  validate :check_easuser  ,:on => :create,:if => :input_oacode?
  #校验 不能重复
   validates_uniqueness_of :username,:on => :create ,:message => "你的用户名已经被占用了，重输一个^_^"

  validates :netname ,  :presence => true, :length => {:within => 2..10}
  #EAS用户校验 
  validates_uniqueness_of :oacode ,:on => :create,:message => "该OA号码已在本论坛注册，不可再用。",:if => :input_oacode? 

  #用户图像--------------------------------------------------------------------------------------------
  attr_accessible :avatar
  has_attached_file :avatar,
    :styles => {  :big => "120x120>", :normal => "48x48>", :small => "16x16>" ,:large => "64*64>"},
    :default_sytle => "normal",
    :url => "/uploadfiles/:class/:attachment/:id/:style.:extension",
    :path => ":rails_root/public/uploadfiles/:class/:attachment/:id/:style.:extension"
  validates_attachment_content_type :avatar,
    :content_type =>[ "image/gif",'image/png','image/x-png','image/jpeg','image/pjpeg','image/jpg'],
    :message => "头像文件需要是图片格式。如：png,jpg.jpeg,gif等"

#-------------------------------------------------------------------------------------------------------
  has_many :topics
  has_many :replies


  # password 是个虚拟属性
  def password
    @password
  end
  
  def password=(password)
    @password=password
    return if password.blank?
    create_new_salt
    self.encrypted_password = User.encrypted_password(self.password,self.salt)
  end

  def oapass
    @oapass
  end

  def oapass=(oapass)
    @oapass=oapass
  end


  def self.authentication(name,password="")
    user = User.find_by_username(name)
    if user
      expected_password = encrypted_password(password.to_s,user.salt)
      p expected_password
      if expected_password != user.encrypted_password
        user = nil
      end
    end    
    user
  end
 
  def admin?
    self.isadmin?
  end
 
  private
  
  def input_oacode?
    oacode.present?
  end
  #实现SHA1加密
  def self.encrypted_password(password ="",salt)
    string_to_hash = password + "song" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end  
  #给salt赋值
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  #判断是否为初始密码
  def check_defalutpass?
     oacode == oapass or oapass == '111111'
  end    
  #eas用户校验 
  def check_easuser
    if not  oacode.blank?
      a =  ActiveRecord::Base.connection.select_all "select username,checkpass('#{oacode}' ,'#{oapass}' ) ispass,status from oadb.system_users where fnumber= '#{oacode}' "
      if a.count == 0 
        errors.add(:oacode,'不存在该OA编码!,你是何人？')
      else
        u = a.first
        errors.add(:oapass ,"OA用户名密码不正确！")  if  u["ispass"] != "1"     
  #      errors.add(:oacode ,"真实姓名与OA不一致！")  if  u["username"] != truename
        errors.add(:oacode ,"该OA用户已被禁用！") if u["status"] != "1"
        self.netname = u["username"] if netname.blank?
        self.username = oacode 
        self.truename = u["username"]
        self.password = oapass
      end
    end
  end
  
  def chcck_easuser_status(fnumber)
    a= ActiveRecord::Base.connection.select_all "select status from oadb.system_users where fnumber = '#{fnumber}'"
    u = a.first
    return u["status"] == '1'
  end      
end
