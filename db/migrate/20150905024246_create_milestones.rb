class CreateMilestones < ActiveRecord::Migration
  def change
    create_table :milestones do |t|
      t.string :title
      t.date :due_date
      t.text :description
      t.integer :status
      t.integer :milestone_type
      t.string :icon
      t.belongs_to :feedback_author, class_name: 'Person'

      t.timestamps null: false
    end

    create_table :person_milestones do |t|
      t.belongs_to :person, index: true
      t.belongs_to :milestone, index: true
      t.date :completion_date

      t.timestamps null: false
    end
  end
end
