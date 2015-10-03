# == Schema Information
#
# Table name: tech_roles
#
#  id         :integer          not null, primary key
#  name       :string
#  icon       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TechRole < ActiveRecord::Base
end
