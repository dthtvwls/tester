desc 'Deploy app'
task :deploy, [:app_name] do |t, args|
    with_defaults app_name: Haikunator.haikunate

    tag = Haikunator.haikunate
    image_name = "#{ENV['AWS_ACCOUNT_ID']}.dkr.ecr.#{ENV['AWS_REGION']}.amazonaws.com/player:#{tag}"
    s3_bucket = "elasticbeanstalk-#{ENV['AWS_REGION']}-#{ENV['AWS_ACCOUNT_ID']}"
    s3_key = "#{tag}.zip"

    system('$(aws ecr get-login)')
    system("docker build -t #{image_name} #{Rails.root}") || exit
    system("docker push #{image_name}") || exit

    tempfile = Tempfile.new(tag)

    Zip::File.open(tempfile.path, Zip::File::CREATE) do |zipfile|
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

    Aws::S3::Resource.new.bucket(s3_bucket).object(s3_key).upload_file(tempfile.path)

    Aws::ElasticBeanstalk::Client.new.create_application_version(
        application_name: args[:app_name],
        version_label: tag,
        process: true,
        source_bundle: { s3_bucket: s3_bucket, s3_key: s3_key }
    )
end
