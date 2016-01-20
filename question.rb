require_relative 'schoo_database'
require_relative 'model_base'

class Question < ModelBase
  attr_accessor :id, :title, :body, :author_id

  DB_TABLE = 'questions'

  def self.table
    DB_TABLE
  end

  def self.find_by_id( id )
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL

    return nil if data.empty?
    self.new(data.first)
  end

  def self.find_by_author_id( author_id )
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.author_id = ?
    SQL

    data.map { |row| self.new( row ) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionFollow.most_liked_questions(n)
  end

  def initialize( options = {} )
    @id,
    @title,
    @body,
    @author_id = options.values_at( 'id', 'title', 'body', 'author_id')
  end

  def author
    User.find_by_id( author_id )
  end

  def replies
    Reply.find_by_question_id( id )
  end

  def followers
    QuestionFollow.followers_for_question_id( id )
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end

end
