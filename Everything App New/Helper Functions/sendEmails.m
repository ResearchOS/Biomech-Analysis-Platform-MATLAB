function []=sendEmails(subject, message)

%% PURPOSE: SEND AN EMAIL

%% Email parameters
smtpServer = 'smtp.gmail.com';
[senderEmail, senderAppPassword] = mailConfig();
recipientEmail = 'mtillman14@gmail.com';

%% Set up SMTP settings
setpref('Internet', 'SMTP_Server', smtpServer);
setpref('Internet', 'SMTP_Username', senderEmail);
setpref('Internet', 'SMTP_Password', senderAppPassword);

%% Make a secure connection
% https://www.mathworks.com/matlabcentral/answers/315648-why-do-i-get-the-error-error-using-sendmail-line-172-530-5-7-0-must-issue-a-starttl-command-fi
props = java.lang.System.getProperties;
props.setProperty( 'mail.smtp.starttls.enable', 'true' ); % Works without this, but why not keep it in?

% https://www.mathworks.com/matlabcentral/answers/1672544-using-gmail-after-may-30-2022
props.setProperty('mail.smtp.auth','true');

%% Compose and send the email
sendmail(recipientEmail, subject, message);