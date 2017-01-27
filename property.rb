class Property
  attr_accessor :title, :address, :prop_type, :address, :rate, :max_guests, :email, :phone_number, :id
  EMPTY_REGEXP = /(?!\s*$)/
  EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  FLOAT_REGEXP = /\A[-+]?[0-9]*\.?[0-9]+\Z/
  INTEGER_REGEXP = /\A[0-9]\Z/
  TYPE_REGEXP = /holiday home|apartment|private room/

  def initialize(atributes = {})
    @id = atributes[:id]
    @title = atributes[:title]
    @address = atributes[:address]
    @prop_type = atributes[:prop_type]
    @rate = atributes[:rate]
    @max_guests = atributes[:max_guests]
    @email = atributes[:email]
    @phone_number = atributes[:phone_number]
  end

  def save
    unless Property.find(@id)
      $db.execute "INSERT INTO Properties(Id,
      Title,
      Property_type,
      Address,
      Nightly_rate_in_EUR,
      Max_guests,
      Email,
      Phone_number)
      VALUES('#{@id}',
      '#{@title}',
      '#{@prop_type}',
      '#{@address}',
      '#{@rate}',
      '#{@max_guests}',
      '#{@email}',
      '#{@phone_number}')"
    else
      $db.execute "UPDATE Properties
      SET Title = '#{@title}',
      Address = '#{@address}',
      Property_type = '#{@prop_type}',
      Nightly_rate_in_EUR = '#{@rate}',
      Max_guests = '#{@max_guests}',
      Email = '#{@email}',
      Phone_number = '#{@phone_number}'
      WHERE Id = '#{@id}'"
    end
  end

  def self.list
    props = $db.execute "SELECT * FROM Properties WHERE  Email is not null"
    puts "No properties found." if props.to_a.empty?
    props
  end

  def self.find(id)
    property = $db.execute "SELECT * FROM Properties WHERE Id = '#{id}'"

    if property.to_a.empty?
      #puts "No properties found."
      return
    else
      Property.new({id: property[0]['Id'],
      title: property[0]['Title'],
      prop_type: property[0]['Property_type'],
      address: property[0]['Address'],
      rate: property[0]['Nightly_rate_in_EUR'],
      max_guests: property[0]['Max_guests'],
      email: property[0]['Email'],
      phone_number: property[0]['Phone_number']})
    end
  end

  def self.question(attr)
    attr.to_s.sub('@','').capitalize + ":"
  end

  def self.validate_hash
    regexp_hash = { :@email => EMAIL_REGEXP, :@rate => FLOAT_REGEXP, :@max_guests => INTEGER_REGEXP, :@prop_type => TYPE_REGEXP}
    regexp_hash.default = EMPTY_REGEXP
    regexp_hash
  end

end