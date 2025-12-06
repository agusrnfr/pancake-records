module ApplicationHelper
  def favicon_path(filename)
    file_path = Rails.public_path.join(filename)
    version = File.exist?(file_path) ? File.mtime(file_path).to_i : Time.current.to_i
    "#{filename}?v=#{version}"
  end
end
