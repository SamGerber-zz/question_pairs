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
end
