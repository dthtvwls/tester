

desc 'Deploy app'
task :deploy, [:app_name] do |t, args|

    tag = SecureRandom.hex
    image_name = "#{ENV['AWS_ACCOUNT_ID']}.dkr.ecr.#{ENV['AWS_REGION']}.amazonaws.com/player:#{tag}"
    tempfile_path = Tempfile.new(tag).path
    s3_bucket = "elasticbeanstalk-#{ENV['AWS_REGION']}-#{ENV['AWS_ACCOUNT_ID']}"
    s3_key = "#{tag}.zip"

    puts "This is version #{tag}"
    `$(aws ecr get-login)`
    puts 'Building image...'
    `docker build -t #{image_name} #{Rails.root}`
    puts 'Pushing to ECR...'
    `docker push #{image_name}`

    Zip::File.open(tempfile_path, Zip::File::CREATE) do |zipfile|
        zipfile.get_output_stream('Dockerrun.aws.json') do |f|
            f.puts({
                AWSEBDockerrunVersion: '1',
                Image: {
                    Name: image_name,
                    Update: 'true'
                },
                Ports: [{ ContainerPort: '8080' }]
            }.to_json)
        end
    end

    Aws::S3::Resource.new.bucket(s3_bucket).object(s3_key).upload_file(tempfile_path)

    Aws::ElasticBeanstalk::Client.new.create_application_version(
        application_name: args[:app_name],
        version_label: tag,
        process: true,
        source_bundle: { s3_bucket: s3_bucket, s3_key: s3_key }
    )

    puts "Finished creating #{tag}"
end
