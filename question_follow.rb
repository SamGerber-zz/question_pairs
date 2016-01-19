require_relative 'schoo_database'

class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def initialize( options = {} )
    @id, @user_id, @question_id = options.values_at( 'id', 'user_id', 'question_id')
  end

  def self.find_by_id( id )
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_follows.id = ?
    SQL

    return nil if data.empty?
    self.new(data.first)
  end
end
