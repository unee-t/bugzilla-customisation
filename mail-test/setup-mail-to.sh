#!/bin/bash

STAGE=${STAGE:-dev}

EMAILPREFIX=""
if test "$STAGE" != "prod"
then
	EMAILPREFIX="${STAGE}."
fi

if ! test "$1"
then 
	echo Please specify an email address
	exit 1
fi

USER=$(aws --profile ins-${STAGE} ssm get-parameters --names SES_SMTP_USERNAME --with-decryption --query Parameters[0].Value --output text)
PASS=$(aws --profile ins-${STAGE} ssm get-parameters --names SES_SMTP_PASSWORD --with-decryption --query Parameters[0].Value --output text)
SENDER=$(aws --profile ins-${STAGE} ssm get-parameters --names SES_VERIFIED_SENDER --with-decryption --query Parameters[0].Value --output text)

cat << END > index.js
var nodemailer = require('nodemailer');

// create reusable transporter object using the default SMTP transport
var transporter = nodemailer.createTransport({
    host: 'email-smtp.us-west-2.amazonaws.com',
    port: 465,
    secure: true, // use SSL
    auth: {
        user: '${USER}',
        pass: '${PASS}'
    }
});

// setup e-mail data with unicode symbols
var mailOptions = {
    from: '${SENDER}', // SES_VERIFIED_SENDER
    to: '${1}', // list of receivers
    subject: 'Hello ✔', // Subject line
    text: 'Hello world ?', // plaintext body
    html: '<b>Hello world ?</b>' // html body
};

// send mail with defined transport object
transporter.sendMail(mailOptions, function(error, info){
    if(error){
        return console.log(error);
    }
    console.log('Message sent: ' + info.response);
});
END
