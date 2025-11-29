# Configure LetterOpenerWeb to store emails in custom location
LetterOpenerWeb.configure do |config|
  # Set the location where emails will be stored
  # Default value is `tmp/letter_opener`
  config.letters_location = Rails.root.join('tmp', 'my_mails')
end