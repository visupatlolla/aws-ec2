# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX - License - Identifier: Apache - 2.0

require 'aws-sdk-ec2'

# Lists the IDs and current states of available
# Amazon Elastic Compute Cloud (Amazon EC2) instances.
#
# @param ec2_resource [Aws::EC2::Resource] An initialized EC2 resource object.
# @example
#   list_instance_ids_states(Aws::EC2::Resource.new(region: 'us-east-1'))
def list_instance_ids_states(ec2_resource, region)
  response = ec2_resource.instances
  if response.count.zero?
    puts 'No instances found.'
  else
    puts 'Outputting instance types'

    fileName = "hosts-" + region + ".csv"
    open(fileName, 'w') do |f|
      f << "Instance Id, State, Instance Type, Hostclass, Tags"
      f << "\n"

      response.each do |instance|
        f << "#{instance.id}, #{instance.state.name}, #{instance.instance_type}, "

        tags = ", "
        hostclass = ""
        instance.tags.each do |tag|
          tags = tags + "#{tag.key}:#{tag.value};"
          if tag.key == "hostclass"
            f << "#{tag.value} "
          end
        end
        f << tags
        f << "\n"
    end
    end
  end
rescue StandardError => e
  puts "Error getting information about instances: #{e.message}"
end

#Full example call:
def run_me
  region = ''
  # Print usage information and then stop.
  if ARGV[0] == '--help' || ARGV[0] == '-h'
    puts 'Usage:   ruby ec2-ruby-example-get-all-instance-info.rb REGION'
    puts 'Example: ruby ec2-ruby-example-get-all-instance-info.rb us-east-1'
    exit 1
    # If no values are specified at the command prompt, use these default values.
  elsif ARGV.count.zero?
    region = 'us-east-1'
    # Otherwise, use the values as specified at the command prompt.
  else
    region = ARGV[0]
  end
  ec2_resource = Aws::EC2::Resource.new(region: region, http_read_timeout:300)
  list_instance_ids_states(ec2_resource, region)
end

run_me if $PROGRAM_NAME == __FILE__
