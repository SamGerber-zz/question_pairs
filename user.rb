require_relative 'schoo_database'

class User
  attr_accessor :id, :fname, :lname

  def initialize( options = {} )
    @id, @fname, @lname = options.values_at( 'id', 'fname', 'lname')
  end

  def self.find_by_id( id )
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

    return nil if data.empty?
    self.new(data.first)
  end

  def self.find_by_name( fname, lname )
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname )
      SELECT
        *
      FROM
        users
      WHERE
        users.fname = ? AND users.lname = ?
    SQL

    return nil if data.empty?
    data.map do |row|
      self.new(row)
    end
  end

  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        CAST( COUNT( question_likes.id ) AS FLOAT) / COUNT( DISTINCT questions.id ) AS karma
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.author_id = id;
    SQL
    data.first['karma']
  end
end
