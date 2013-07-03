# JoinCollection

Join an array of mongoid docs with target objects by specified relation and delegation fields


## Installation

Add this line to your application's Gemfile:

    gem 'join_collection'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install join_collection


## Usage

### Initialize a JoinCollection object

The class JoinCollection itself is a wrapper around an array of mongoid docs, so to initialize it, simply put

    user_collection = JoinCollection.new(users) # where users is an array of mongoid docs

We will call what we put inside the initilizer the source objects.

### Specifiy parameters to join docs

To use any of the `join_*` functions, make sure you provide the following parameters.

1. The 1st parameter is the `target_name`, which is used as the prefix for the delegation fields.
2. The 2nd parameter is the `target_class`, which is used to query target objects.
3. The 3rd parameter is the `options`, which is not optional and it must be a hash containing a `:relation` key and a `:delegation` key.
  - The key `:relation` points to another hash, which specifies the foreign key to primary key for the type of join relation.
  - The key `:delegation` also points to a hash, which specifies the `:fields` of the target object to be delegated to the doc in the source objects.
    In a has_many relation, you can also privide a `:if` conditional block to specify which target object to delegate if there are many target objects.

## Examples

### Join docs with `belongs_to` relation

Assume we have a `user belongs_to site` relationship, and the Site class has the field `url`.

    user_collection = JoinCollection.new(users)
    user_collection.join_to(:site, Site, :relation => {:site_id => :id}, :delegation => {:fields => [:url]})

After this, all the source objects, the users, in the user_collection will have the field `site_url`

    user_collection.source_objects.first.site_url   # => "http://..."

### Join docs with `has_one` relation

Assume we have a `user has_one profile` relationship, and the Profile class has the field `twitter`.

    user_collection = JoinCollection.new(users)
    user_collection.join_one(:profile, Profile, :relation => {:user_id => :id}, :delegation => {:fields => [:twitter]})

After this, all the source objects, the users, in the user_collection will have the field `profile_twitter`

    user_collection.source_objects.first.profile_twitter   # => "https://twitter.com/..."

### Join docs with `has_many` relation

Assume we have a `user has_many contacts` relationship, and the Contact class has the field `phone`.

    user_collection = JoinCollection.new(users)
    user_collection.join_many(:contacts, Contact, :relation => {:user_id => :id},
      :delegation => {:if => lambda { |x| x.is_active? }, :fields => [:phone]})

After this, all the source objects, the users, in the user_collection will have the field `contact_phone`

    user_collection.source_objects.first.contact_phone   # => "0987-654-321"

### Notes

If you specify a delegation field which is identical to the target name of that join type, the whole object(s) will be captured.

    user_collection.join_to(:site, Site, :relation => {:site_id => :id}, :delegation => {:fields => [:site]})
    user_collection.source_objects.first.site   # get the site the user belongs to

    user_collection.join_one(:profile, Profile, :relation => {:user_id => :id}, :delegation => {:fields => [:profile]})
    user_collection.source_objects.first.profile   # get the profile the user has

    user_collection.join_many(:contacts, Contact, :relation => {:user_id => :id}, :delegation => {:fields => [:contacts]})
    user_collection.source_objects.first.contacts   # get all contacts the user has


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
