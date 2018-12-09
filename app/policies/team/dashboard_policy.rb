class Team::DashboardPolicy < Struct.new(:user, :dashboard)
  attr_reader :user, :dashboard

  def initialize(user, dashboard)
    @user = user
    @dashboard = dashboard
  end

  def index?
    @user
  end
end
