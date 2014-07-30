# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)


seeds_dir = File.expand_path(File.dirname(__FILE__)) + "/seeds/"

#Roles and permissions
Role.create :name => 'anonymous'
Role.create :name => 'restricted_user'
Role.create :name => 'user'
Role.create :name => 'moderator'
Role.create :name => 'admin'
Role.create :name => 'banned'

#Create base users
u = User.new({:name => 'anonymous', :role => Role.find_by_name('anonymous'), :password => 'D5yO7g9lc3Si7tdew7rl', :password_confirmation =>  'D5yO7g9lc3Si7tdew7rl', :description => "This represents the anonymous user"})
u.save(:validate => false)
u = User.new({:name => 'admin', :role => Role.find_by_name('admin'), :password => 'changeme', :password_confirmation =>  'changeme', :description => "This user has full privileges"})
u.save(:validate => false)

#Create boards
NameSpace.create({ :name => 'discussions'})
NameSpace.create({:name => 'requests'})
NameSpace.create({:name => 'New boards', :parent_space => NameSpace.find_by_name('requests')})
NameSpace.create({:name => 'development'})

#Create Static Wiki Pages

Wiki.create :name => 'Homepage'
WikiRevisions.create({:wiki => Wiki.find_by_name('Homepage'), :content => 'Welcome to the *lol* IB Board', :revision => 1, :user => User.find_by_name('admin')})
Wiki.create :name => 'Rules'
WikiRevisions.create({:wiki => Wiki.find_by_name('Rules'), :content => File.read(seeds_dir + 'Rules.txt'), :revision => 1, :user => User.find_by_name('admin')})
Wiki.create :name => 'News'
WikiRevisions.create({:wiki => Wiki.find_by_name('News'), :content => 'Welcome to the *lol* IB Board.', :revision => 1, :user => User.find_by_name('admin')})
