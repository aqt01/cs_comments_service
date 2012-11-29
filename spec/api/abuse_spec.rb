require 'spec_helper'

def create_comment_flag(comment_id, user_id)
  create_flag("/api/v1/comments/" + comment_id + "/abuse_flags", user_id)
end

def create_thread_flag(thread_id, user_id)
  create_flag("/api/v1/threads/" + thread_id + "/abuse_flags", user_id)
end

def create_flag(put_command, user_id)
   if user_id.nil?
    put put_command
  else
    put put_command, user_id: user_id
  end
end

describe "app" do
  describe "abuse" do
    before(:each) { init_without_subscriptions }
    describe "flag a comment as abusive" do
      it "create or update the abuse_flags on the comment" do
        comment = Comment.first
        prev_abuse_flaggers = comment.abuse_flaggers
        create_comment_flag("#{comment.id}", User.first.id)

        comment = Comment.find(comment.id)
        comment.abuse_flaggers.length.should == prev_abuse_flaggers.length + 1
        # verify that the thread doesn't automatically get flagged
        comment.comment_thread.abuse_flaggers.length.should == 0
      end
      it "returns 400 when the comment does not exist" do
        create_comment_flag("does_not_exist", User.first.id)
        last_response.status.should == 400
      end
      it "returns 400 when user_id is not provided" do
        create_comment_flag("#{Comment.first.id}", nil)
        last_response.status.should == 400
      end
      #Would like to test the output of to_hash, but not sure how to deal with a Moped::BSON::Document object
      #it "has a correct hash" do
      #  create_flag("#{Comment.first.id}", User.first.id)
      #  Comment.first.to_hash
      #end
    end
    describe "flag a thread as abusive" do
      it "create or update the abuse_flags on the thread" do
        comment = Comment.first
        thread = comment.comment_thread
        prev_abuse_flaggers = thread.abuse_flaggers
        create_thread_flag("#{thread.id}", User.first.id)

        comment = Comment.find(comment.id)
        comment.comment_thread.abuse_flaggers.length.should == prev_abuse_flaggers.length + 1
        # verify that the comment doesn't automatically get flagged
        comment.abuse_flaggers.length.should == 0
      end
      it "returns 400 when the thread does not exist" do
        create_thread_flag("does_not_exist", User.first.id)
        last_response.status.should == 400
      end
      it "returns 400 when user_id is not provided" do
        create_thread_flag("#{Comment.first.comment_thread.id}", nil)
        last_response.status.should == 400
      end
      #Would like to test the output of to_hash, but not sure how to deal with a Moped::BSON::Document object
      #it "has a correct hash" do
      #  create_thread_flag("#{Comment.first.comment_thread.id}", User.first.id)
      #  Comment.first.comment_thread.to_hash
      #end
    end
  end
end
