class UserPresenter
  def initialize(user)
    @user = user
  end

  def as_json(options = {})
    if @user.nil?
      {}
    else
      {
        id: @user.id,
        email: @user.email,
        name: @user.name,
        nickname: @user.nickname,
        roles: @user.roles.map(&:name)
      }
    end
  end
end
