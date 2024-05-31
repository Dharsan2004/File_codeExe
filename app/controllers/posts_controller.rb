# app/controllers/posts_controller.rb
require 'rest-client'

class PostsController < ApplicationController
  def index
    @posts = Post.page(params[:page]).per(7)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      send_to_express_api(@post)
      redirect_to posts_path, notice: 'Post was successfully created and executed.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :file, :image)
  end

  def send_to_express_api(post)
    code_file = download_blob_to_tempfile(post.file)
    input_file = create_tempfile_from_content(post.content)

    response = RestClient.post('http://localhost:8000/execute',
                               { code: code_file, input: input_file },
                               { content_type: :multipart })
    Rails.logger.info("Response from Express API: #{response.body}")
    puts "Response from Express API: #{response.body}"
    post.update(content: response.body) # Save the response to the post content

  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error("Error from Express API: #{e.response}")
    post.update(content: e.response) 
    puts "Error from Express API: #{e.response}"
  ensure
    code_file.close
    code_file.unlink # Deletes the temp file
    input_file.close
    input_file.unlink # Deletes the temp file
  end

  def download_blob_to_tempfile(blob)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write(blob.download)
    tempfile.rewind
    tempfile
  end

  def create_tempfile_from_content(content)
    tempfile = Tempfile.new
    tempfile.binmode
    tempfile.write(content)
    tempfile.rewind
    tempfile
  end
end
