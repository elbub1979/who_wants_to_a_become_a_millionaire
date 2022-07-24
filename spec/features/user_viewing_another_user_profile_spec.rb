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
                                            current_level: 1,
                                            prize: 10_000,
                                            created_at: '21 июля, 21:51',
                                            finished_at: '21 июля, 22:01')
  end

  let!(:game_w_questions2) do
    FactoryBot.create(:game_with_questions, user: users[1],
                                            current_level: 5,
                                            prize: 100_000,
                                            fifty_fifty_used: true,
                                            created_at: '22 июля, 21:51')
  end

  before do
    visit '/'
    login_as users[0]
  end

  feature 'visit your page' do
    before { click_link 'Вадик' }

    scenario 'should the path to the corresponding user' do
      expect(page).to have_current_path "/users/#{users[0].id}"
    end

    scenario 'should the corresponding user name' do
      expect(page).to have_content users[0].name
    end

    scenario 'should a link to edit the current user' do
      expect(page).to have_link 'Сменить имя и пароль'
    end
  end

  feature "visit someone else's page" do
    before { click_link 'Миша' }

    scenario 'should the path to the corresponding user' do
      expect(page).to have_current_path "/users/#{users[1].id}"
    end

    scenario 'should the corresponding user name' do
      expect(page).to have_content users[1].name
    end

    scenario 'should no link to edit the user' do
      expect(page).not_to have_link 'Сменить имя и пароль'
    end

    feature 'game_w_questions1' do
      scenario 'should have money status' do
        expect(page).to have_content('деньги')
      end

      scenario 'should have date 21 июля, 21:51' do
        expect(page).to have_content('21 июля, 21:51')
      end

      scenario 'should have 10 000 rub prize' do
        expect(page).to have_content('10 000 ₽')
      end

      scenario 'should have 1 question number' do
        expect(page).to have_content(game_w_questions1.current_level)
      end
    end

    feature 'game_w_questions2' do
      scenario 'should have in progress status' do
        expect(page).to have_content('в процессе')
      end

      scenario 'should have date 21 июля, 21:51' do
        expect(page).to have_content('22 июля, 21:51')
      end

      scenario 'should have 50x50 hint used' do
        expect(page).to have_css('span.label.label-primary.game-help-used', text: '50/50')
      end

      scenario 'should have 5 question number' do
        expect(page).to have_content(game_w_questions2.current_level)
      end
    end
  end
end

