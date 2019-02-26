require 'pry'

class Dog
  attr_accessor :name, :breed, :id
  
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end
  

  def self.create_table
     db_table = DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, breed TEXT);")
   end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    new_dog = DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES ('#{self.name}', '#{self.breed}');")
    self.id = DB[:conn].last_insert_row_id
   # table = DB[:conn].execute("SELECT * FROM dogs")
   # table.each do |dog|
   #     if dog[1] == self.name
   #       self.id = dog[0]
    #    end
    #  end
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
  end

  def self.find_by_id(id)
    searched_dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = #{id}")
    found_dog = self.new(name: searched_dog[0][1], breed: searched_dog[0][2], id: searched_dog[0][0])
  end

  def self.find_or_create_by(dog)
    found_dog = nil
    all_dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{dog[:name]}' AND breed = '#{dog[:breed]}';")
        if all_dogs == []
          found_dog = self.create(dog)
        else
          found_dog = self.find_by_id(all_dogs[0][0])
        end
      found_dog
  end

  def self.new_from_db(db_dog)
    self.new(name: db_dog[1], breed: db_dog[2], id: db_dog[0])
  end

  def self.find_by_name(dog_name)
    searched_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{dog_name}'")
    self.find_by_id(searched_dog[0][0])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = '#{self.name}' WHERE id = '#{self.id}'")
  end

end