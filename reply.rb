require_relative 'schoo_database'
require_relative 'model_base'

class Reply < ModelBase
  attr_accessor :id, :question_id, :user_id, :reply_id, :body

  DB_TABLE = 'replies'

  def self.table
    DB_TABLE
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

  def self.find_by_user_id( user_id )
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    data.map { |row| self.new(row) }
  end

  def self.find_by_question_id( question_id )
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.question_id = ?
    SQL

    data.map { |row| self.new(row) }
  end

  def initialize( options = {} )
    @id,
    @question_id,
    @user_id,
    @reply_id,
    @body = options.values_at( 'id',
                               'question_id',
                               'user_id',
                               'reply_id',
                               'body')
  end

  def author
    User.find_by_id( user_id )
  end

  def question
    Question.find_by_id( question_id )
  end

  def parent_reply
    Reply.find_by_id( reply_id )
  end

  def child_replies
    all_replies_to_question = Reply.find_by_question_id( question_id )
    all_replies_to_question.select { |reply| reply.reply_id == id }
  end

end
