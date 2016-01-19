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
end
