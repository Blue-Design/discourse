require 'rails_helper'

describe Admin::StaffActionLogsController do
  it "is a subclass of AdminController" do
    expect(Admin::StaffActionLogsController < Admin::AdminController).to eq(true)
  end

  let!(:user) { log_in(:admin) }

  context '.index' do

    it 'works' do
      xhr :get, :index
      expect(response).to be_success
      expect(::JSON.parse(response.body)).to be_a(Array)
    end
  end

  context '.diff' do
    it 'can generate diffs for theme changes' do
      theme = Theme.new(user_id: -1, name: 'bob')
      theme.set_field(:mobile, :scss, 'body {.up}')
      theme.save!

      record = StaffActionLogger.new(Discourse.system_user)
        .log_theme_change(theme, theme_fields: [
          {
            name: 'scss',
            target: 'mobile',
            value: 'body {.down}'
          }
        ])


      xhr :get, :diff, id: record.id
      expect(response).to be_success

      parsed = JSON.parse(response.body)
      expect(parsed["side_by_side"]).to include("up")
      expect(parsed["side_by_side"]).to include("down")
    end
  end
end
