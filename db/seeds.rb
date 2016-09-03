# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
role = Role.new
role.name = "admin"
role.save

role = Role.new
role.name = "receptionist"
role.save

role = Role.new
role.name = "invitee"
role.save

user = User.new
user.email = 'marol.ichigo@gmail.com'
user.password = user.password_confirmation = '12345678'
user.save
