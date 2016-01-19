require_relative 'schoo_database'

class Reply
  attr_accessor :id, :question_id, :user_id, :reply_id, :body

  def initialize( options = {} )
    @id, @question_id, @user_id, @reply_id, @body = options.values_at( 'id', 'question_id', 'user_id', 'reply_id', 'body')
  end

  def self.find_by_id( id )
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL

    return nil if data.empty?
    self.new(data.first)
  end
end
