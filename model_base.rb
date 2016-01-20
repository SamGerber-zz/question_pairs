class ModelBase

  def self.table
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table}
      WHERE
        #{self.table}.id = ?
    SQL

    return nil if data.empty?
    self.new(data.first)
  end

  def self.all
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table}

    SQL

    data.map { |row| self.new(row) }
  end

  def self.where(options = {})
    if options.is_a?(Hash)
      filter = options.map { |k, v| "#{self.table}.#{k} = '#{v}'" }
      filter_string = filter.join(" AND ")
    elsif options.is_a?(String)
      filter_string = options
    else
      raise 'You really messed up'
    end

    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table}
      WHERE
        #{filter_string}
    SQL

    data.map { |row| self.new(row) }
  end

  ###########################################################
  #SPLIT
  ###########################################################

  def self.method_missing(method_name, *args)
    method_name = String(method_name)
    method_words = method_name.split('_')
    unless method_words[0] == 'find' && method_words[1] == 'by'
      super(*args)
    else
      column_names = method_name.gsub('find_by_', '').split('_and_')
      options = Hash[*column_names.zip(args).flatten]
      self.where(options)
    end
  end

  def save
    id ? save_update : save_insert
  end

  def save_insert
    ivar_string  = instance_variables.join(', ').delete('@')
    qmark_string = (['?']*instance_variables.length).join(', ')
    ivars = instance_variables.map { |var| instance_variable_get(var) }

    QuestionsDatabase.instance.execute(<<-SQL, *ivars)
      INSERT INTO
        #{self.class.table} ( #{ivar_string} )
      VALUES
        (#{qmark_string})
    SQL
    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def save_update
    ivars = instance_variables.reject { |ivar| ivar == :@id }
    set_string = ivars.join( " = ? , ").delete('@') + " = ?"
    ivar_values = ivars.map { |var| instance_variable_get(var) }

    QuestionsDatabase.instance.execute(<<-SQL, *ivar_values, self.id)
      UPDATE
        #{self.class.table}
      SET
        #{set_string}
      WHERE
        #{self.class.table}.id = ?
    SQL
  end

end
