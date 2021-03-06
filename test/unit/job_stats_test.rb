require 'test_helper'

class JobStatsTest < ActiveSupport::TestCase

  SUCCESSFUL_COUNT = 3
  FAILED_COUNT = 2
  RUNNING_COUNT = 4
  RESCHEDULED_COUNT = 2
  QUEUED_COUNT = 6

  setup do

    dump_jobs
    dump_database

    (1..3).each do |i|
      job = Factory(:successful_job)
      job.destroy
    end
    
    (1..2).each do |i|
      job = Factory(:failed_job)
      job.destroy
    end

    (1..4).each do |i|
      Factory(:running_job)
    end

    (1..RESCHEDULED_COUNT).each do |i|
      Factory(:rescheduled_job)
    end
    
    (1..6).each do |i|
      Factory(:queued_job)
    end
  end
  
  test "when the database is down, job stats should report properly" do
    Mongoid.master.expects(:stats).raises(Mongo::ConnectionFailure, 'mock database exception')
    stats = JobStats.stats
    assert_equal ({error: "Backend Down"}), stats
  end

  test "job stats should report properly" do
    stats = JobStats.stats
    assert_equal SUCCESSFUL_COUNT, stats["success"]
    assert_equal FAILED_COUNT, stats["failed"]
    assert_equal RUNNING_COUNT , stats["running"]
    assert_equal RESCHEDULED_COUNT, stats["rescheduled"]
    assert_equal QUEUED_COUNT, stats["queued"]
    assert_equal 30, (stats["avg_runtime"]/1000).to_i
  end

  
end