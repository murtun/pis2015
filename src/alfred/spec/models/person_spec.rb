require 'rails_helper'

describe 'Person' do

  before do
    @master = Person.new :name => 'Obiwan', :email => 'obi@jedi.com'
    @padawan = Person.new :name => 'Luke', :email => 'luke@jedi.com'
    @project = Project.new :name => 'Equilibrar la fuerza'
    @ms = Milestone.new :title => 'Destruir Death Star'
    @techRole = TechRole.new :name => 'Jedi'
    @skill = Skill.new :name => 'Mover piedras con la mente'
    @skill2 = Skill.new :name => 'uso del sable'
    @nota = Note.new :text => 'Usar la fuerza', :author => @padawan, :visibility => 'me'
    @technology = Technology.new :name => 'X Wings'
    @technology2 = Technology.new :name => 'Falcon millenium'


    @ms.notes<<(@nota)
    @master.mentees<<(@padawan)
    @master.projects<<(@project)
    @padawan.projects<<(@project)
    @project.technologies<<(@technology)
    @project.technologies<<(@technology2)
    @padawan.milestones<<(@ms)
    @master.skills<<(@skill)
    @master.skills<<(@skill2)
    @master.tech_role=@techRole
    @padawan.tech_role=@techRole





    @padawan.save!
    @master.save!


  end
  it 'debería tener a Look como discípulo' do
    expect(@master.mentees).to include(@padawan)
  end
  it 'debería tener a Obiwan como maestro' do
    expect(@padawan.mentors).to include(@master)
  end
  it 'debería tener a Equilbrar la fuerza como pryecto' do
    expect(@padawan.projects).to include(@project)
  end
  it 'Look deberia ser parte de equilibrar la fuerza' do
    expect(@project.people).to include(@padawan)
  end
  it 'el master también debería tener a Equilbrar la fuerza como pryecto' do
    expect(@master.projects).to include(@project)
  end
  it 'el master y padawan son jedi' do
    expect(@master.tech_role).to eq(@techRole)
    expect(@padawan.tech_role).to eq(@techRole)
  end
  it 'el master tiene skilles' do
    expect(@master.skills).to include(@skill)
    expect(@master.skills).to include(@skill2)
  end
  it 'el milestone tiene a padawan asociado' do
    expect(@ms.people).to include(@padawan)
  end
  it 'el milestone no tiene a master asociado' do
    expect(@ms.people).not_to include(@master)
  end

  it 'el milestone tiene nota asociada hecha por padawan' do
    expect(@ms.notes).to include(@nota)
    expect(@nota.author).to eq(@padawan)
  end

  it 'el proyecto tiene 2 technoloies' do
    expect(@project.technologies).to include(@technology)
    expect(@project.technologies).to include(@technology2)
  end


end
