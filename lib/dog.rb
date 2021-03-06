require 'pry'


class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil , name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
     CREATE TABLE IF NOT EXISTS dogs(
       id INTEGER PRIMARY KEY,
       name TEXT,
       breed TEXT
     );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
     sql = <<-SQL
     DROP TABLE IF EXISTS dogs;
     SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
     sql = <<-SQL
     INSERT INTO dogs (name, breed) VALUES (?, ?);
     SQL
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
     self
   end
  end

  def self.create(name:, breed:)
   dogs = self.new(name: name, breed: breed)
   dogs.save
   dogs
  end

  def self.find_by_id(id)
    sql = <<-SQL
     SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    doe = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
    doegs = doe[0]
    if doe.empty?
     dogs = self.create(name: name, breed: breed)
    else
     dogs = self.new(id: doegs[0], name: doegs[1], breed: doegs[2])
    end
    dogs
  end

  def self.new_from_db(row)
   id = row[0]
   name = row[1]
   breed = row[2]
   self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
   sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? LIMIT 1
   SQL
   DB[:conn].execute(sql, name).map do |row|
       self.new_from_db(row)
     end.first
  end

  def update
   sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE ID = ?
   SQL
   DB[:conn].execute(sql, self.name, self.breed, self.id)
  end







end
