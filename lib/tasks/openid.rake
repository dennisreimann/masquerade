desc 'GC OpenID store'
task :gc_openid_store => :environment do
  ActiveRecordStore.new.cleanup
end