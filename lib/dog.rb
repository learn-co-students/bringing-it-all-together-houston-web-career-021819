require 'pry'
class Dog
    attr_accessor :id, :name, :breed
    def initialize(id: nil, name:, breed:)
      self.id = id
      self.name = name
      self.breed = breed
    end

    def self.create_table
       DB[:conn].execute(
           "CREATE TABLE dogs(
               id INTEGER PRIMARY KEY,
               name TEXT,
               breed TEXT
           )"
       ) 
    end

    def self.drop_table
        DB[:conn].execute(
            "DROP TABLE dogs;"
        )
    end

    def save
       result= DB[:conn].execute(
            "INSERT INTO dogs(name, breed) VALUES(?, ?)",
            [self.name, self.breed]
        ) 

        self.id = DB[:conn].last_insert_row_id # IMPORTANT
        self
        #Dog.new(id:dog_id, name:name, breed:breed)

    end

    def self.create(name:, breed:)
        dog = Dog.new(name:name, breed:breed)
        dog.save

    end

    def self.find_by_id(id)
       result = DB[:conn].execute(
            "SELECT * FROM dogs WHERE id = #{id}"
        )
       Dog.new(id:result[0][0], name:result[0][1], breed:result[0][2])
    end

    def self.find_or_create_by(dog)

        results = DB[:conn].execute(
            "SELECT * FROM dogs WHERE name = '#{dog[:name]}' AND breed = '#{dog[:breed]}';"
        )
        if results == []
            self.create(dog)#return Dog.create(dog[:name],dog[:breed])
        else
            self.find_by_id(results[0][0]) #return Dog.find_by_id(results[0][0])
        end

   end

   def self.new_from_db(row)
    dog = self.create(name:row[1], breed:row[2])
    dog.id = row[0]
    dog
   end

   def self.find_by_name(name)
      results = DB[:conn].execute(
          "SELECT * FROM dogs WHERE name = ?",
          ["#{name}"]
      )

      dog = self.new_from_db(results[0])
   end

   def update
    DB[:conn].execute("UPDATE dogs SET name = ? WHERE id = ?", [self.name, self.id])
   end
end 