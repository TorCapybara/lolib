class NameSpace < ActiveRecord::Base
  include FlagShihTzu

  has_flags 1 => :index

  validates :name, :presence => true

  has_many :child_spaces, :class_name => 'NameSpace', :foreign_key => 'parent_id'
  belongs_to :parent_space, :class_name => 'NameSpace', :foreign_key => 'parent_id'
  has_many :board_threads
  has_many :board_accesses
  accepts_nested_attributes_for :board_accesses, :reject_if => proc { false }, :allow_destroy => true

  def update_board_accesses
    board_accesses.each do |board_access|
      board_access.destroy unless board_accesses.role
    end

    Role.all.each do |role|
      if board_accesses.filter_by_role(role.id).none?
        access = BoardAccess.new
        access.role = role
        access.name_space = self
        access.save
      end
    end
  end

  def update_roles(role_hash)
    self.roles.clear

    role_hash.each do |role, value|
      r = Role.find_by_name role if value == 'yes'
      roles << r if r
    end
  end

  def verification_header(format)
    case format
      when 'md5', 'sha1','csv'
        ''
      when 'sfv'
        "; Created by lolib\r\n" <<
            "; \r\n"
      else
        ''
    end
  end

  def verification_file(format)
    content = verification_header(format)
    board_threads.order(:title).each do |board_thread|
      board_thread.images.order(:name).each do |image|
        content <<= image.verification_line(format)
      end
    end
    content
  end

  def self.select_node(spaces)
    result = []
    if spaces.count > 0
      spaces.each do |ns|
        result.concat([[ns.full_path, ns.id]])
        result += select_node(ns.child_spaces.order('sort_order ASC'))
      end
    end
    return result
  end

  def self.select_tree
    ns_roots = NameSpace.where('parent_id is NULL').order('sort_order ASC')
    return select_node(ns_roots)
  end

  def full_path
    return Rails.cache.fetch("space_path_#{id}") do
      if parent_space
        parent_space.full_path + ' / ' + name
      else
        name
      end
    end
  end
end
