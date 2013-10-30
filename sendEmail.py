"""
==============================================================================
Program: sendEmail.py
 Author: Kyle Reese Almryde
   Date: 10/23/2013

 Description: This is a convenience script designed to send emails to a large
 number of people



==============================================================================
"""

import smtplib
from email.mime.text import MIMEText

#uname, pwd are username & password of gmail a/c i am trying to send from

server = smtplib.SMTP('smtp.gmail.com:22')
server.starttls() # get response(220, '2.0.0 Ready to start TLS')
server.login(uname,pwd)  # get response(235, '2.7.0 Accepted')

toaddrs  = ['x...@gmail.com', 'y...@gmail.com' ] # list of To email addresses
msg = MIMEText('email body')
msg['Subject'] = 'Psychology experiment -- 4 credits'
server.sendmail(fromaddr, toaddrs, msg.as_string())



msg = """
Hello {0},

My name is Kyle Almryde. I am a participating researcher in the Psychology 101
experiment program. You indicated an interest in participating in the kinds of
research we do. I would like to invite you to participate in a study of
language and the brain that is being conducted by researchers in the Department
of Speech, Language, and Hearing Sciences.

This study will help us better understand the nature of language learning and
learning disabilities in the human brain.

The study has 2 parts:
1)    Take a battery of language and reading tests
2)    Complete an MRI scan of the brain

You will receive 2 experiment credits for the testing portion of the study and 2
credits for the MRI portion of the study. If you choose to enroll in this
experiment it is assumed you agree to participate in the MRI portion of the
study. If you cannot or are not interested in the MRI portion, we have another
option for you (described below).

People who participate in the MRI study must meet certain criteria.
1)   No metal in or on your body that cannot be removed (other than fillings).
     Because the MRI uses a magnet to make images, it is absolutely crucial that
     there is no ferromagnetic metal of any kind on or in your body at the time
     of the scan.  This includes body piercings and permanent retainers. This is
     for your safety.

2)   Anti-psychotic or anti-seizure medications:  Although these medications are
     important for those who need them, we cannot enroll people who are
     currently taking any of these types of drugs.

3)  You are comfortable in tight spaces: We must place you inside the MRI in
    addition to placing several sensitive devices on and around your head, which
    can make some people who normally do not like tight spaces uncomfortable. It
    can be even worse for someone who is claustrophobic.

4)   Your age:  You must be age 50 or younger.

If you do not qualify for the MRI portion of the study, we would still like to
invite you to participate in the behavioral portion of our study, and you will
receive 3 experiment credits (just no pictures of your brain).

If you could give me some days and times when you are free for approximately
1hr 30mins, I can schedule you for the behavioral testing portion of our study.
Additionally, if you have any questions, please do not hesitate to ask.

Thank you for your interest in our study, we could not do our research without
you!

Best,

Kyle Almryde
""".format(name)


#=============================== START OF MAIN ===============================

def main():
    pass


if __name__ == '__main__':
    main()
