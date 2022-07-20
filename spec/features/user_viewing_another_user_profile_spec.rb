require 'rails_helper'

RSpec.feature 'USER viewing another user profile', type: :feature do
  let!(:users) do
    [
      FactoryBot.create(:user, name: 'Вадик', balance: 5000),
      FactoryBot.create(:user, name: 'Миша', balance: 3000)
    ]
  end

  let!(:game_w_questions1) do
    FactoryBot.create(:game_with_questions, user: users[1],
                                            finished_at: Time.now)
  end

  let!(:game_w_questions2) do
    FactoryBot.create(:game_with_questions, user: users[1],
                                            current_level: 5,
                                            prize: 100_000)
  end

  before do
    login_as users[0]
  end

  scenario 'visit your page' do
    visit '/'

    click_link 'Вадик'

    expect(page).to have_current_path "/users/#{users[0].id}"
    expect(page).to have_content users[0].name
    expect(page).to have_link 'Сменить имя и пароль'

    expect(page).not_to have_selector('.users-table table')

  end

  scenario "visit someone else's page" do
    visit '/'

    click_link 'Миша'

    expect(page).not_to have_selector('.users-table table')

    expect(page).to have_current_path "/users/#{users[1].id}"
    expect(page).to have_content users[0].name
    expect(page).not_to have_link 'Сменить имя и пароль'

    expect(page).to have_content 'Дата'
    expect(page).to have_content I18n.l(Time.now, format: :short)

    expect(page).to have_content 'Вопрос'
    expect(page).to have_content('в процессе')
    expect(page).to have_content('деньги')

    expect(page).to have_content('Выигрыш')
    expect(page).to have_content('100 000 ₽')
    expect(page).to have_content('0 ₽')
  end
end
