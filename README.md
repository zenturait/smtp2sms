SMTP2SMS
==============

Simple SMTP Server that sends SMS via Danish provider InMobile

## Requirement
+ Docker
+ API Key from InMobile

## Installation
1. Pull image from Docker Hub

	```bash
	$ sudo docker pull zenturacp/smtp2sms
	```

## Usage
1. Run Container

	```bash
	$ sudo docker run -p 25:25 \
			-e MAILDOMAIN=mail.example.com -e SMTP_USER=user:pwd \
			-e SMS_APIKEY=apikey -e SMS_FROM=from/sender \
			--name smtp2sms -d zenturacp/smtp2sms
	```

## Reference
+ [InMobile - Awsome SMS provider](https://www.inmobile.dk/)

## Special Thanks
+ [CatAtNight or Minghou Ye - i borrowed a lot from that repo](https://github.com/catatnight/docker-postfix)

