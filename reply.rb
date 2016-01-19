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

  def self.find_by_user_id( user_id )
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    return nil if data.empty?
    data.map do |row|
      self.new(row)
    end
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

    return nil if data.empty?
    data.map do |row|
      self.new(row)
    end
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
    all_replies_to_question.select do |reply|
      reply.reply_id == self.id
    end
  end

  def save
    id ? save_update : save_insert
  end

  def save_insert
    QuestionsDatabase.instance.execute(<<-SQL, question_id, user_id, reply_id, body)
      INSERT INTO
        replies ( question_id, user_id, reply_id, body )
      VALUES
        (?, ?, ?)
    SQL
    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def save_update
    QuestionsDatabase.instance.execute(<<-SQL, question_id, user_id, reply_id, body, id)
      UPDATE
        replies
      SET
        question_id = ?,
        user_id = ?,
        reply_id = ?,
        body = ?
      WHERE
        replies.id = ?
    SQL
  end
end
