class Settings < ActiveRecord::Base
private
  def self.create_if_not_exists(key, value)
    setting = self.find_by_key(key)
    unless (setting)
      setting = Settings.create :key => key, :value => value
    end
    setting
  end
end
