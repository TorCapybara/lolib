class Statistics < ActiveRecord::Base
  COUNTER_TYPES = %w(hit download image_thumb image_design image_full)

  validates :counter_type, inclusion: {in: COUNTER_TYPES}

  def self.counter_types
    return COUNTER_TYPES
  end

end
