# == Schema Information
#
# Table name: milestones
#
#  id                 :integer          not null, primary key
#  title              :string
#  due_date           :date
#  description        :text
#  status             :integer          default(0)
#  icon               :string
#  feedback_author_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  category_id        :integer
#  start_date         :date
#  author_id          :integer
#  completed_date     :date
#  deleted_date       :date
#  highlighted        :boolean          default(FALSE), not null
#

require 'rails_helper'

describe 'Milestone' do

  before do
   # @master = Person.new :name => 'Obiwan'
   #  @padawan = Person.new :name => 'Luke'
   #  @project = Project.new :name => 'Equilibrar la fuerza'

    @ms = Milestone.new :title => 'Destruir Death Star', :description => 'Mision para destruir al Death Star'
    @ms2 = Milestone.new :title => 'Visitar a Yoda', :description => 'A Yoda visitar debes'
    @nota = Note.new :text => 'Apuntar al agujero usando la fuerza', :visibility => 'me'
    @nota2 = Note.new :text => 'Usá la fuerza Look', :visibility => 'every_body'
    @ms.notes<<(@nota)
    @ms.notes<<(@nota2)

    @res = Resource.new :url => 'www.espadalaser.com'
    @ms2.resources<<(@res)

    @cat = Category.new :name => 'Importante'
    @ms.category=@cat

    @tag = Tag.new :name => 'Ataque'
    @ms.tags<<(@tag)

    @ms.save!
    @ms.reload
    @ms2.save!
    @ms2.reload


  end

  it 'debria tener 2 notas' do
    expect(@ms.notes).to include(@nota)
    expect(@ms.notes).to include(@nota2)
  end
  it 'el resource deberia estar en ms2' do
    expect(@ms.resources).not_to include(@res)
    expect(@ms2.resources).to include(@res)
  end
  it 'debería tener 1 categoria' do
    expect(@ms.category).to eq(@cat)
  end
  it 'debe tener tag Ataque' do
    expect(@ms.tags).to include(@tag)
  end

  it 'debe cambiar el estado a done' do

    expect(@ms.get_next_status).to eq(:done)
  end

end
