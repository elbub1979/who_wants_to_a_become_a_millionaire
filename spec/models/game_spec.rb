# (c) goodprogrammer.ru

require 'rails_helper'
require 'support/my_spec_helper' # наш собственный класс с вспомогательными методами

# Тестовый сценарий для модели Игры
# В идеале - все методы должны быть покрыты тестами,
# в этом классе содержится ключевая логика игры и значит работы сайта.
RSpec.describe Game, type: :model do
  # пользователь для создания игр
  let(:user) { FactoryBot.create(:user) }

  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  # Группа тестов на работу фабрики создания новых игр
  describe '#create_game!' do
    before { generate_questions(60) }

    context 'new correct game' do
      before { Game.create_game_for_user!(user) }

      it 'should number of games has increased' do
        expect(Game.count).to eq(1)
      end

      it 'should 15 numbers of games questions' do
        expect(GameQuestion.count).to eq(15)
      end

      it 'should number of question has not changed' do
        expect(Question.count).to eq(0)
      end
    end

    context 'check game content' do
      let(:game) { Game.create_game_for_user!(user) }

      it 'should be current user in game user author' do
        expect(game.user).to eq(user)
      end

      it 'should be game in progress' do
        expect(game.status).to eq(:in_progress)
      end

      it 'should be 15 questions in game' do
        expect(game.game_questions.size).to eq(15)
      end

      it 'should be 15 levels of questions' do
        expect(game.game_questions.map(&:level)).to eq (0..14).to_a
      end
    end
  end

  describe '#correct_answer_key' do
    context 'get current game status' do
      let(:question) { game_w_questions.current_game_question }

      it 'should be game in progress' do
        expect(game_w_questions.status).to eq(:in_progress)
      end

      it 'should be game level 0' do
        expect(game_w_questions.current_level).to eq(0)
      end

      context 'moving to the next level' do
        before { game_w_questions.answer_current_question!(question.correct_answer_key) }

        it 'should transition to a higher level' do
          expect(game_w_questions.current_level).to eq(1)
        end

        it 'should the current question has become the previous one' do
          expect(game_w_questions.previous_game_question).to eq(question)
        end

        it 'should current question is not equal to the previous one' do
          expect(game_w_questions.current_game_question).not_to eq(question)
        end

        it 'should be game in progress' do
          expect(game_w_questions.status).to eq(:in_progress)
        end

        it 'should be game continues' do
          expect(game_w_questions.finished?).to be_falsey
        end
      end
    end
  end

  describe '#take_money' do
    context 'get current game status' do

      it 'should be game in progress' do
        expect(game_w_questions.status).to eq(:in_progress)
      end

      it 'should be game continues' do
        expect(game_w_questions.finished?).to be_falsey
      end

      it 'should be game balance 0' do
        expect(user.balance).to eq(0)
      end

      context 'taking the money' do
        before { game_w_questions.update_attribute(:current_level, 3) }
        before { game_w_questions.take_money! }

        it 'should be game status is money' do
          expect(game_w_questions.status).to eq(:money)
        end

        it 'should be game finished' do
          expect(game_w_questions.finished?).to be_truthy
        end

        it 'should be game prize is 300' do
          expect(game_w_questions.prize).to eq(300)
        end

        it 'should be user balance is 300' do
          expect(user.balance).to eq(300)
        end
      end
    end
  end

  describe '#current_game_question' do
    let(:question) { game_w_questions.game_questions.first }

    it 'should get current game question' do
      expect(game_w_questions.current_game_question).to eq(question)
    end
  end

  describe '#previous_level' do
    it 'should get previous game level' do
      expect(game_w_questions.previous_level).to eq(-1)
    end
  end

  describe '.status' do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy
    end

    it ':won' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it ':fail' do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ':timeout' do
      game_w_questions.created_at = 1.hour.ago
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ':money' do
      expect(game_w_questions.status).to eq(:money)
    end
  end

  describe '#answer_current_question!' do
    let(:question) { game_w_questions.current_game_question }

    context 'when correct answer' do
      before { game_w_questions.answer_current_question!(question.correct_answer_key) }

      it 'game not finish' do
        expect(game_w_questions.finished?).to be false
      end

      it 'game not failed' do
        expect(game_w_questions.is_failed?).to be false
      end
    end

    context 'when wrong answer' do
      before { game_w_questions.answer_current_question!('c') }

      it 'game finish' do
        expect(game_w_questions.finished?).to be true
      end

      it 'game status' do
        expect(game_w_questions.status).to eq(:fail)
      end

      it 'game prize' do
        expect(game_w_questions.prize).to eq(0)
      end
    end
  end

  context 'last question' do
    before { game_w_questions.current_level = Question::QUESTION_LEVELS.max }
    before { game_w_questions.answer_current_question!(question.correct_answer_key) }

    it 'game finish' do
      expect(game_w_questions.finished?).to be true
    end

    it 'fail status game' do
      expect(game_w_questions.is_failed).to be false
    end

    it 'game status' do
      expect(game_w_questions.status).to eq(:won)
    end

    it 'game prize' do
      expect(game_w_questions.prize).to eq(1_000_000)
    end
  end

  context 'after time out' do
    before { game_w_questions.created_at = 1.hour.ago }
    before { game_w_questions.answer_current_question!(question.correct_answer_key) }

    it 'game finish' do
      expect(game_w_questions.finished?).to be true
    end

    it 'game status' do
      expect(game_w_questions.status).to eq(:timeout)
    end

    it 'fail status game' do
      expect(game_w_questions.is_failed).to be true
    end

    it 'game prize' do
      expect(game_w_questions.prize).to eq(0)
    end
  end
end
