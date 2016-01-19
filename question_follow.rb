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

  def self.followers_for_question_id( question_id )
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        users
      JOIN question_follows ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL

    data.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id( user_id )
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        questions
      JOIN question_follows ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL

    data.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id, COUNT(*) follows
      FROM
        questions
      JOIN question_follows ON questions.id = question_follows.question_id
      GROUP BY
        questions.id, questions.title, questions.body, questions.author_id
      ORDER BY
        follows DESC
      LIMIT ?;
    SQL
    # data.map { |question| Question.new(question) }
  end
end
