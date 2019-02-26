require 'sqlite3'
require 'pry'
require_relative '../config/environment.rb'
class Dog
    attr_accessor :name, :breed, :id
    def initialize(params = {})
        @name = params[:name]
        @breed = params[:breed]
        @id = nil
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
    end

    def save
        results = DB[:conn].execute("INSERT INTO dogs(name, breed) VALUES (?, ?);",
        [
            self.name,
            self.breed
        ])

        self.id = DB[:conn].last_insert_row_id #check SQLite3 for documentation

       new_dog = Dog.new(name: self.name, breed: self.breed)
       new_dog.id = self.id
       return new_dog
    end
    
    def self.create(name: name, breed: breed)
        new_dog = Dog.new({name: name, breed: breed})
        new_dog.save
    end

    def self.find_by_id(id)
        ins = "SELECT * FROM dogs WHERE id = #{id}"
        results = DB[:conn].execute(ins)
        new_id = results[0][0]
        new_name = results[0][1]
        new_breed = results[0][2]
        new_dog = Dog.new({name:new_name,breed:new_breed})
        new_dog.id = id
        return new_dog
    end

    def self.find_or_create_by(name: name,breed: breed)
        ins = "SELECT id FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'"
        results = DB[:conn].execute(ins)
        if results[0] == nil
            return Dog.create(name:name,breed:breed)
        else
            return Dog.find_by_id(results[0][0])
        end
    end

    def self.new_from_db(array)
        new_dog = Dog.new(name: array[1], breed: array[2])
        new_dog.id = array[0]
        return new_dog
    end

    def self.find_by_name(name)
        ins = "SELECT * FROM dogs WHERE name = '#{name}'"
        results = DB[:conn].execute(ins)
        return Dog.new_from_db(results[0])
    end

    def update 
        DB[:conn].execute("UPDATE dogs SET name = ? WHERE id = ?",
        [
            self.name,
            self.id
        ])  
    end
end

