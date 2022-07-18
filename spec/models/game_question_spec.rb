# (c) goodprogrammer.ru

require 'rails_helper'

# Тестовый сценарий для модели игрового вопроса,
# в идеале весь наш функционал (все методы) должны быть протестированы.
RSpec.describe GameQuestion, type: :model do

  # задаем локальную переменную game_question, доступную во всех тестах этого сценария
  # она будет создана на фабрике заново для каждого блока it, где она вызывается
  let(:game_question) { FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  describe '#variants' do
    it 'should correct answer variants' do
      expect(game_question.variants).to eq({ 'a' => game_question.question.answer2,
                                             'b' => game_question.question.answer1,
                                             'c' => game_question.question.answer4,
                                             'd' => game_question.question.answer3 })
    end
  end

  describe '#answer_correct?' do
    it 'correct .answer_correct?' do
      expect(game_question.answer_correct?('b')).to be_truthy
    end
  end

  describe '#text' do
    it 'should correct text delegates' do
      expect(game_question.text).to eq(game_question.question.text)
    end
  end

  describe 'should correct level delegates' do
    it 'correct level delegates' do
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  describe '#help_hash' do
    context 'check audience_help hint' do
      context 'without audience_help hint' do

        it 'should empty audience_help in help hash' do
          expect(game_question.help_hash).not_to include(:audience_help)
        end

        context 'with audience_help hint' do
          before { game_question.add_audience_help }

          let(:ah) { game_question.help_hash[:audience_help] }

          it 'should help hash included audience_help' do
            expect(game_question.help_hash).to include(:audience_help)
          end

          it 'should all answers keys in the hint' do
            expect(ah.keys).to contain_exactly('a', 'b', 'c', 'd')
          end
        end
      end
    end
  end

  describe '#fifty_fifty' do
    context 'without fifty_fifty hint' do
      it 'should empty fifty_fifty in help hash' do
        expect(game_question.help_hash).not_to include(:fifty_fifty)
      end

      context 'with fifty_fifty hint' do
        before { game_question.add_fifty_fifty }

        let(:ff) { game_question.help_hash[:fifty_fifty] }

        it 'should help hash included fifty_fifty' do
          expect(game_question.help_hash).to include(:fifty_fifty)
        end

        it 'should be to elements in help hash' do
          expect(ff.size).to eq(2)
        end

        it 'should be correct answer in help hash' do
          expect(ff).to include(game_question.correct_answer_key)
        end
      end
    end
  end

  describe '#friend_call' do
    context 'without friend_call hint' do
      it 'should empty friend_call in help hash' do
        expect(game_question.help_hash).not_to include(:friend_call)
      end

      context 'with friend_call hint' do
        before { game_question.add_friend_call }

        let(:fc) { game_question.help_hash[:friend_call] }

        it 'should help hash included friend_call' do
          expect(game_question.help_hash).to include(:friend_call)
        end

        it 'should be few mandatory words in friend_call hint' do
          expect(fc).to include('считает, что это вариант')
        end

        it 'should be friend_call hint a string' do
          expect(fc.class.to_s).to eq('String')
        end
      end
    end
  end

  describe '#correct_answer_key' do
    it 'correct answer key' do
      expect(game_question.correct_answer_key).to eq('b')
    end
  end
end
