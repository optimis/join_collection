require 'spec_helper'


class User; include Mongoid::Document; end
class Post; include Mongoid::Document; end

describe JoinCollection do
  let!(:user1) { User.new :mysql_id => 1, :name => 'Bob' }
  let!(:user2) { User.new :mysql_id => 2, :name => 'Joe' }

  let!(:post1) { Post.new :mysql_id => 1, :user_id => 1, :content => 'text 1', :published => true }
  let!(:post2) { Post.new :mysql_id => 2, :user_id => 2, :content => 'text 2', :published => true }
  let!(:post3) { Post.new :mysql_id => 3, :user_id => 2, :content => 'text 3', :published => false }


  context 'extract options' do
    before do
      @user_collection = JoinCollection.new([user1])
    end

    it 'raise an argument error if relation hash is not found in options' do
      expect{@user_collection.join_many(:post, Post, :delegation => {})}.to raise_error(ArgumentError)
    end

    it 'raise an argument error if delegation hash is not found in options' do
      expect{@user_collection.join_many(:post, Post, :relation => {})}.to raise_error(ArgumentError)
    end
  end

  # post1 belongs_to user1
  describe '#join_to' do
    before do
      @post_collection = JoinCollection.new([post1])
      User.stub(:where).and_return([user1])
    end

    it 'should call User.where' do
      User.should_receive(:where).with(:mysql_id.in => [1]).and_return([user1])
      @post_collection.join_to(:user, User, :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:mysql_id]})
    end

    it 'should catch the target object if the delegation field name equals to the target' do
      @post_collection.join_to(:user, User, :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:user]})
      expect(@post_collection.source_objects.first.user).to eq(user1)
    end

    it 'should have correct value in delegation field if the target object has the field' do
      @post_collection.join_to(:user, User, :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:name]})
      expect(@post_collection.source_objects.first.user_name).to eq('Bob')
    end

    it 'should raise no method error if the target object does not have the field' do
      expect{
        @post_collection.join_to(:user, User, :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:email]})
      }.to raise_error(NoMethodError)
    end
  end

  # user1 has_one post1
  describe '#join_one' do
    before do
      @user_collection = JoinCollection.new([user1])
      Post.stub(:where).and_return([post1])
    end

    it 'should call Post.where' do
      Post.should_receive(:where).with(:user_id.in => [1]).and_return([post1])
      @user_collection.join_one(:post, Post, :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:mysql_id]})
    end

    it 'should catch the target object if the delegation field name equals to the target name' do
      @user_collection.join_one(:post, Post, :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:post]})
      expect(@user_collection.source_objects.first.post).to eq(post1)
    end

    it 'should have correct value in delegation field if the target object has the field' do
      @user_collection.join_one(:post, Post, :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:content]})
      expect(@user_collection.source_objects.first.post_content).to eq('text 1')
    end

    it 'should raise no method error if the target object does not have the field' do
      expect{
        @user_collection.join_one(:post, Post, :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:location]})
      }.to raise_error(NoMethodError)
    end
  end

  # user2 has_many posts which are post2 and post3
  describe '#join_many' do
    before do
      @user_collection = JoinCollection.new([user2])
      Post.stub(:where).and_return([post2, post3])
    end

    it 'should catch the whole target objects if the delegation field name equals to the plural target name' do
      @user_collection.join_many(:post, Post,
        :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:posts]})
      expect(@user_collection.source_objects.first.posts).to eq([post2, post3])
    end

    it 'should have correct values in delegation fields if no conditional block given' do
      @user_collection.join_many(:post, Post,
        :relation => {:user_id => :mysql_id}, :delegation => {:fields => [:content, :published]})
      expect(@user_collection.source_objects.first.post_content).to eq('text 2')
      expect(@user_collection.source_objects.first.post_published).to be_true
    end

    it 'should have correct values in delegation fields if a conditional block given' do
      @user_collection.join_many(:post, Post,
        :relation => {:user_id => :mysql_id},
        :delegation => {:if => lambda { |x| x.published == false }, :fields => [:content, :published]})
      expect(@user_collection.source_objects.first.post_content).to eq('text 3')
      expect(@user_collection.source_objects.first.post_published).to be_false
    end
  end
end
