require_relative 'schoo_database'
require_relative 'model_base'

class User < ModelBase
  attr_accessor :id, :fname, :lname
  DB_TABLE = 'users'

  def self.table
    DB_TABLE
  end

  def initialize( options = {} )
    @id, @fname, @lname = options.values_at( 'id', 'fname', 'lname')
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

    data.map { |row| self.new(row) }
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
        CAST(COUNT(likes.id) AS FLOAT) / COUNT(DISTINCT q.id) AS karma
      FROM
        questions AS q
      LEFT OUTER JOIN
        question_likes AS likes ON q.id = likes.question_id
      WHERE
        q.author_id = 9;
        q.author_id = #{id};
    SQL

    data.first['karma']
  end
end
