desc 'GC OpenID store'
task :gc_openid_store => :environment do
  ActiveRecordOpenIDStore.new.cleanup
end