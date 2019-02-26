require 'pry'

class Dog
    attr_accessor :name, :breed, :id

    def initialize(name: , breed: , id: nil)
        self.name = name
        self.breed = breed
        self.id = id
    end

    def self.create_table
        DB[:conn].execute('CREATE TABLE dogs (id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT)')
    end

    def self.drop_table 
        DB[:conn].execute('DROP TABLE dogs')
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name,breed) VALUES 
        ('#{name}','#{breed}')")
        self.id = DB[:conn].last_insert_row_id
        
        Dog.new(name: name, breed: breed, id: self.id)
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
    end

    def self.find_by_id(id_value)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = #{id_value}")[0]

        Dog.new_from_db(dog)
    end

    def self.find_or_create_by(name: ,breed:)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", [name, breed])[0]
        if result == nil
            test_dog = Dog.create(name: name, breed: breed)
            return test_dog
        end
        result_dog = Dog.new_from_db(result)
    end

    def self.new_from_db(row)
        new_dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    end
    
    def self.find_by_name(name)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", [name])[0]
        self.new_from_db(result)
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", [self.name, self.breed, self.id])

    end



end