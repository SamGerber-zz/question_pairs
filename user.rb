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
end
