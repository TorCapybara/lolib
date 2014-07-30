class Wiki < ActiveRecord::Base
  self.per_page = 25

  validates :name, :presence => true
  validates :name, :uniqueness => { :case_sensitive => false }

  has_many :revisions, :class_name => 'WikiRevisions'
  accepts_nested_attributes_for :revisions

  def to_param
    name
  end

  def last_revision
    revisions.order('revision DESC').first
  end
end
