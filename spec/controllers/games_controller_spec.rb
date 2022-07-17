require 'rails_helper'
require 'support/my_spec_helper' # наш собственный класс с вспомогательными методами

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  describe '#show' do
    context 'anonymous user' do
      before { get :show, id: game_w_questions.id }

      it 'should to redirect to sign in user' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should be a alert message' do
        expect(flash[:alert]).to eq(I18n.t('controllers.errors.authenticate'))
      end

      it 'should be a 302 status code' do
        expect(response.status).to eq(302)
      end
    end

    context 'authorized user' do
      before { sign_in user }

      context 'show your own game' do
        before { get :show, id: game_w_questions.id }

        let(:game) { assigns(:game) }

        it 'the game is expected to continue' do
          expect(game.finished?).to be_falsey
        end

        it 'the player is correct' do
          expect(game.user).to eq(user)
        end

        it 'should be a 200 status code' do
          expect(response.status).to eq(200)
        end

        it 'should render show template' do
          expect(response).to render_template('show')
        end
      end

      context 'not show alien game' do
        let(:alien_game) { FactoryBot.create(:game_with_questions) }

        before { get :show, id: alien_game.id }

        it 'should be a 302 status code' do
          expect(response.status).to eq(302)
        end

        it 'should redirect to root path' do
          expect(response).to redirect_to(root_path)
        end

        it 'should be a alert message' do
          expect(flash[:alert]).to eq(I18n.t('controllers.games.not_your_game'))
        end
      end
    end
  end

  describe '#create' do
    context 'anonymous user' do
      before { put :create }

      it 'should to redirect to sign in user' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should be a alert message' do
        expect(flash[:alert]).to eq(I18n.t('controllers.errors.authenticate'))
      end

      it 'should be a 302 status code' do
        expect(response.status).not_to eq(200)
      end
    end

    context 'authorized user' do
      before { sign_in user }

      context 'should create new game' do
        before do
          generate_questions(15)
          post :create
        end

        let(:game) { assigns(:game) }

        it 'the game is expected to continue' do
          expect(game.finished?).to be_falsey
        end

        it 'the player is correct' do
          expect(game.user).to eq(user)
        end

        it 'should be a 200 status code' do
          expect(response.status).to eq(200)
        end

        it 'should redirect to game' do
          expect(response).to redirect_to(game_path(game))
        end

        it 'should get notice message' do
          expect(flash[:notice]).to be
        end
      end
    end

  end

  describe '#answer' do
    context 'anonymous user' do
      before { put :answer, id: game_w_questions.id, letter: 'a' }

      it 'should to redirect to sign in user' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should be a alert message' do
        expect(flash[:alert]).to eq(I18n.t('controllers.errors.authenticate'))
      end

      it 'should be a 302 status code' do
        expect(response.status).to be(302)
      end
    end

    context 'authorized user' do
      before { sign_in user }

      context 'correct answer' do
        before { put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key }

        let(:game) { assigns(:game) }

        it 'the game is expected to continue' do
          expect(game.finished?).to be_falsey
        end

        it 'should to increment current level' do
          expect(game.current_level).to be > 0
        end

        it 'should be a 302 status code' do
          expect(response.status).to eq(302)
        end

        it 'should to redirect to game' do
          expect(response).to redirect_to(game_path(game))
        end

        it 'should to empty flashes' do
          expect(flash.empty?).to be_truthy
        end
      end

      context 'incorrect answer' do
        before { put :answer, id: game_w_questions.id, letter: 'c' }

        let(:game) { assigns(:game) }

        it 'should the end game' do
          expect(game.finished?).to be_truthy
        end

        it 'should to redirect to user template' do
          expect(response).to redirect_to(user_path(user))
        end

        it 'should be a alert message' do
          expect(flash[:alert]).to be
        end
      end
    end
  end

  describe '#take_money' do
    context 'anonymous user' do
      before { put :take_money, id: game_w_questions.id }

      it 'should to redirect to log in user' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should be a alert message' do
        expect(flash[:alert]).to eq(I18n.t('controllers.errors.authenticate'))
      end

      it 'should be a 302 status code' do
        expect(response.status).to eq(302)
      end
    end

    context 'authorized user' do
      before { sign_in user }
      before { game_w_questions.update_attribute(:current_level, 2) }

      context 'take money' do
        before { put :take_money, id: game_w_questions.id }

        let(:game) { assigns(:game) }

        it ' expected the end game' do
          expect(game.finished?).to be_truthy
        end

        it 'expect prize' do
          expect(game.prize).to eq(200)
        end

        it 'should to redirect to user template' do
          expect(response).to redirect_to(user_path(user))
        end

        context 'user status' do
          before { user.reload }

          it 'expect user balance' do
            expect(user.balance).to eq(200)
          end

          it 'should be a warning message' do
            expect(flash[:warning]).to be
          end
        end
      end
    end
  end

  describe '#help' do
    context 'anonymous user' do
      before { get :help, id: game_w_questions.id, help_type: :audience_help }

      it 'should to redirect to log in user' do
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should be a alert message' do
        expect(flash[:alert]).to eq(I18n.t('controllers.errors.authenticate'))
      end

      it 'should be a 302 status code' do
        expect(response.status).to eq(302)
      end
    end

    context 'authorized user' do
      before { sign_in user }

      it 'should empty audience_help in help hash' do
        expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
      end

      it 'should false in audience_help_used' do
        expect(game_w_questions.audience_help_used).to be_falsey
      end

      context 'get audience help' do
        before { put :help, id: game_w_questions.id, help_type: :audience_help }

        let(:game) { assigns(:game) }

        it 'the game is expected to continue' do
          expect(game.finished?).to be_falsey
        end

        it 'should true in audience_help_used' do
          expect(game.audience_help_used).to be_truthy
        end

        it 'should audience_help in help hash' do
          expect(game.current_game_question.help_hash[:audience_help]).to be
        end

        it 'should all answers keys in the hint' do
          expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
        end

        it 'should to redirect to game' do
          expect(response).to redirect_to(game_path(game))
        end
      end

      context 'get fifty_fifty help' do
        before { put :help, id: game_w_questions.id, help_type: :fifty_fifty }

        let(:game) { assigns(:game) }

        it 'the game is expected to continue' do
          expect(game.finished?).to be_falsey
        end

        it 'should true in fifty_fifty_used' do
          expect(game.fifty_fifty_used).to be_truthy
        end

        it 'should audience_help in help hash' do
          expect(game.current_game_question.help_hash[:fifty_fifty]).to be
        end

        it 'should all answers keys in the hint' do
          expect(game.current_game_question.help_hash[:fifty_fifty].size).to eq(2)
        end

        it 'should all answers keys in the hint' do
          expect(game.current_game_question.help_hash[:fifty_fifty]).to include(game.current_game_question.correct_answer_key)
        end

        it 'should to redirect to game' do
          expect(response).to redirect_to(game_path(game))
        end
      end
    end
  end

  context 'user can not play two games at the same time' do
    before { post :create }

    let(:game) { assigns(:game) }

    it 'should not change current game count' do
      expect(Game.count).to eq(0)
    end

    it 'should not another game' do
      expect(game).to be_nil
    end

    it 'should redirect to current game' do
      expect(response).to redirect_to(game_path(game_w_questions))
    end

    it 'should be a alert message' do
      expect(flash[:alert]).to eq(I18n.t('controllers.errors.authenticate'))
    end
  end
end
