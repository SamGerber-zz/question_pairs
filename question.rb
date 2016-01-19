require_relative 'schoo_database'

class Question
  attr_accessor :id, :title, :body, :author_id

  def initialize( options = {} )
    @id, @title, @body, @author_id = options.values_at( 'id', 'title', 'body', 'author_id')
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

    return nil if data.empty?
    data.map do |row|
      self.new( row )
    end
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

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
    #Maybe make array of Question elements
  end

  def self.most_liked(n)
    QuestionFollow.most_liked_questions(n)
    #Maybe make array of Question elements
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end


  def save
    id ? save_update : save_insert
  end

  def save_insert
    QuestionsDatabase.instance.execute(<<-SQL, title, body, author_id)
      INSERT INTO
        questions ( title, body, author_id )
      VALUES
        (?, ?, ?)
    SQL
    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def save_update
    QuestionsDatabase.instance.execute(<<-SQL, title, body, author_id, id)
      UPDATE
        questions
      SET
        title = ?,
        body = ?,
        author_id = ?
      WHERE
        questions.id = ?
    SQL
  end
end
