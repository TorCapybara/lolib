class Report < ActiveRecord::Base
  self.per_page = 20

  belongs_to :post
  belongs_to :reporter, :class_name => 'User', :foreign_key => 'reporter_id'

  scope :open_reports, -> { where('handled IS NULL') }

end
