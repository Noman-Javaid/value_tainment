json.status :success
if @attachment.url
  json.data do
    json.extract! @attachment.url, :url, :headers
    json.file_type @attachment.file_type_extension
    json.file_size @attachment.file_size_description
  end
else
  json.data nil
end
