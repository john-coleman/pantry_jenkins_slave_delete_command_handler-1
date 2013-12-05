Specs are using a mixture of method stubbing, chef-zero and VCR (https://www.relishapp.com/vcr/vcr/docs).

Stubbed methods are using when the test is testing another functionality and the stub helps to remove dependencies.

chef-zero is used when a call to the chef server is performed, usually a node is created in chef-zero, then the spec will call chef-zero and see if the outcome is the right or wrong.

VCR uses webmock to mock HTTP calls and requests. By default any HTTP call will fail if the code is not run inside 'VCR.use_cassette'. If you want to run code against a jenkins server you should do the following:

VCR.use_cassette('synopsis') do
  your code
end

synopsis is the name of the cassete, where call and responses are stored. The first time VCR will pass everything to the Jenkins server and recording the HTTP activity, the second time it will use the cassette.

Since by default any HTTP call is block, calls to chef-zero will fail. To connect to chef-zero you need to put your code insie inside 'VCR.use_cassette' using the following options:

VCR.use_cassette('synopsis', :record => :all) do
  node = Chef::Node.new
  node.name("host.example.com")
  node.save
  subject.jenkins_username_and_password("host.example.com").should be_nil
end

record: :all always pass any call, so you will be sure that the chef client will always talk to chef-zero.