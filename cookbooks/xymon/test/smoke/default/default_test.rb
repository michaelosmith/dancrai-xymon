# # encoding: utf-8

# Inspec test for recipe xymon::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

#Check that terebithia yum repo is there and enabled
describe yum.repo('xymon') do
  it { should exist }
  it { should be_enabled }
end
