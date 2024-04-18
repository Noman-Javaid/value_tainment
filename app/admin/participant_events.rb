ActiveAdmin.register ParticipantEvent do
  menu priority: 8
  config.batch_actions = false
  actions :all, except: [:destroy, :edit, :new]

  index do
    selectable_column
    id_column
    column :event_datetime
    column :event_name
    column 'Duration (min)' do |event|
      (event.duration / 60.0).round(2) if event.duration
    end
    column :expert
    column :initial
    column 'Participant' do |event|
      event.participant.email
    end
    column :expert_call
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :event_datetime
      row :event_name
      row 'Duration (min)' do |event|
        (event.duration / 60.0).round(2) if event.duration
      end
      row :expert
      row :initial
      row 'Participant' do |event|
        event.participant.email
      end
      row :expert_call
      row :created_at
    end
  end
end
