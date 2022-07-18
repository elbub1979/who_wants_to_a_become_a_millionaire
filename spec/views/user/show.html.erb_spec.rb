require 'rails_helper'

RSpec.describe 'users/show', type: :view do

  # создаем пользователя
  before(:each) do
    assign(:user, FactoryBot.build_stubbed(:user, id: 1, name: 'Илья', balance: 5000))
    assign(:games, FactoryBot.build_stubbed(:game, id: 15, created_at: Time.parse('2016.10.09, 13:00'),
                                                   current_level: 10, prize: 1000))

    params[:user_id] = [1]



    render
  end

  # Проверяем, что шаблон выводит имена игроков
  it 'should render player name' do
    expect(rendered).to match 'Илья'
  end
end
