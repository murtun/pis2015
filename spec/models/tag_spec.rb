# == Schema Information
#
# Table name: tags
#
#  id       :integer          not null, primary key
#  name     :string
#  validity :boolean          default(TRUE), not null
#

require 'rails_helper'

describe 'Tag' do

  before do
    @ms = Milestone.new :title => 'Destruir Death Star', :description=>'destruir Death Star'
    @res = Resource.new :url => 'www.espadalaser.com'
    @ms.resources<<(@res)
    @cat = Category.new :name => 'Importante'
    @ms.category=@cat
    @ms.save!

    @tag = Tag.new :name => 'Ataque'
    @tag.milestones<<(@ms)

  end

  it 'debe tener hito ms' do
    expect(@tag.milestones).to include(@ms)
  end
end
