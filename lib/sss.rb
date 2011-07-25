require "digest/md5"

class Sss
  VERSION = "0.0.2"

  NoBuckets = Class.new(StandardError)
  NoFiles   = Class.new(StandardError)

  attr :files

  def initialize
    @files = []

    @access_key_id     = ENV["AMAZON_ACCESS_KEY_ID"]
    @secret_access_key = ENV["AMAZON_SECRET_ACCESS_KEY"]
  end

  def add_file(file)
    files << [file, File.basename(file)]
  end

  def use_key(key)
    files.last[1] = key if files.any?
  end

  def upload(buckets)
    raise NoBuckets if buckets.empty?
    raise NoFiles   if files.empty?

    connect

    buckets.each do |bucket|
      puts "-----> Copying to #{bucket}"

      files.each do |file, key|
        AWS::S3::S3Object.store(key, File.open(file), bucket, options)
        status(:copied, key, file, options)

        if AWS::S3::S3Object.exists?(key, bucket)
          status(:exists, key, file, options)

          digest = Digest::MD5.file(file).hexdigest

          object = AWS::S3::S3Object.find(key, bucket)

          if digest == object.about["etag"].tr('"', "")
            status(:checksum, key, file, options)
          else
            error("#{key} checksum failed.")
          end
        else
          error("#{key} does not exist.")
        end
      end
    end
  end

  def access(access)
    @access = access
  end

  def cache_control(cache_control)
    @cache_control = cache_control
  end

private
  def status(type, key, file, options)
    if options.any?
      puts "       #{key} -> #{file} (#{options.inspect}) [#{type}]"
    else
      puts "       #{key} -> #{file} [#{type}]"
    end
  end

  def error(message)
    puts "       !! #{message}"
  end

  def connect
    require "aws/s3"

    AWS::S3::Base.establish_connection!(
      access_key_id: @access_key_id,
      secret_access_key: @secret_access_key
    )
  end

  def options
    {}.tap do |ret|
      ret[:access] = @access.to_sym if defined?(@access)
      ret["Cache-Control"] = @cache_control if defined?(@cache_control)
    end
  end
end