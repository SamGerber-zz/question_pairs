require_relative 'schoo_database'

class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def initialize( options = {} )
    @id, @user_id, @question_id = options.values_at( 'id', 'user_id', 'question_id')
  end

  def self.find_by_id( id )
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_likes.id = ?
    SQL

    return nil if data.empty?
    self.new(data.first)
  end

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
    data.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) AS likes
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
    data.first['likes']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        questions
      JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
    SQL
    data.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id, COUNT(*) likes
      FROM
        questions
      JOIN question_likes ON questions.id = question_likes.question_id
      GROUP BY
        questions.id, questions.title, questions.body, questions.author_id
      ORDER BY
        likes DESC
      LIMIT ?;
    SQL
    # data.map { |question| Question.new(question) }
  end
end
