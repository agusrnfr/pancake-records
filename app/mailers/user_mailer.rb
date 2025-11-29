class UserMailer < ApplicationMailer
  default from: 'no-reply@tuapp.com'

  def welcome_email(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    @login_url = 'http://localhost:3000/users/sign_in'
    @edit_password_url = 'http://localhost:3000/backoffice/users/edit'
    mail(to: @user.email, subject: '¡Bienvenido a la aplicación!')
  end
end