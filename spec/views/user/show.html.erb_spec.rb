require 'rails_helper'

RSpec.describe 'users/show', type: :view do

  context 'looking at the users page' do
    before do
      assign(:user, FactoryBot.build_stubbed(:user, name: 'Илья'))

      render
    end

    it 'should get user name on page' do
      expect(rendered).to match 'Илья'
    end
  end

  context 'looking at the user\'s own page' do
    let(:current_user) { assign(:user, FactoryBot.build_stubbed(:user, name: 'Илья')) }

    before do
      allow(view).to receive(:current_user).and_return(current_user)

      render
    end

    it 'should the user to be able to edit' do
      expect(rendered).to match 'Сменить имя и пароль'
    end
  end

  context 'render game partial' do
    before do
      assign(:user, FactoryBot.build_stubbed(:user, name: 'Илья'))
      assign(:games, [FactoryBot.build_stubbed(:game)])
      stub_template 'users/_game.html.erb' => 'User game goes here'
      render
    end

    it 'should get game partial' do
      expect(rendered).to have_content 'User game goes here'
    end
  end
end
