class UpdateDefaultVideoCallRate < ActiveRecord::Migration[6.1]
  def change
    change_column :experts, :video_call_rate, :integer, default: 5
  end
end
