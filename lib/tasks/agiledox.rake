task :agiledox do
  tests = FileList['test/**/*_test.rb']
  tests.each do |file|
    m = %r".*/([^/].*)_test.rb".match(file)
    puts m[1]+" should:\n" 
    test_definitions = File::readlines(file).select {|line| line =~ /.*def test.*/}
    test_definitions.each do |definition|
      m = %r"test_(should_)?(.*)".match(definition)
      puts " - "+m[2].gsub(/_/," ")
    end
    puts "\n" 
  end
end