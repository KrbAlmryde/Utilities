"""
==============================================================================
 Program: sendEmail.py
 Author: Kyle Reese Almryde
   Date: 10/23/2013

 Description: This is a convenience script designed to send emails to a large
 number of people

 Note: This program was modified from source provided by the following,
http://thelivingpearl.com/2014/01/10/sending-email-from-python-using-command-line/

==============================================================================
"""

# from time import sleep
import sys
import smtplib
from email.mime.application import MIMEApplication
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# account setup:
username = 'kyle.almryde'
password = 'xsgetjgktggpitnt'
server = 'smtp.gmail.com:587'


def create_msg(to_address, from_address='', cc_address='', bcc_address='', subject=''):
# create msg - MIME* object
# takes addresses to, from cc and a subject
# returns the MIME* object
    print "Creating message..."
    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg['To'] = to_address
    msg['Cc'] = cc_address
    msg['From'] = from_address
    return msg


def send_email(smtp_address, usr, password, msg, mode):
# send an email
# takes an smtp address, user name, password and MIME* object
# if mode = 0 sends to and cc
# if mode = 1 sends to bcc
    print "Sending Email..."
    server = smtplib.SMTP(smtp_address)
    server.ehlo()
    server.starttls()
    server.ehlo()
    server.login(username,password)
    if (mode == 0 and msg['To'] != ''):
        server.sendmail(msg['From'],(msg['To']+msg['Cc']).split(","), msg.as_string())
    elif (mode == 1 and msg['Bcc'] != ''):
        server.sendmail(msg['From'],msg['Bcc'].split(","),msg.as_string())
    elif (mode != 0 and mode != 1):
        print 'error in send mail bcc'
        print 'email cancled'
        # exit()
    server.quit()


def compose_email(addresses, subject, body, files):
# compose email
# takes all the details for an email and sends it
# address format: list, [0] - to
#                       [1] - cc
#                       [2] - bcc
# subject format: string
# body format: list of pairs [0] - text
#                            [1] - type:
#                                        0 - plain
#                                        1 - html
# files is list of strings
    print "Composing message..."
    # addresses
    to_address = addresses[0]
    cc_address = addresses[1]
    bcc_address = addresses[2]

    # create a message
    msg = create_msg(to_address, cc_address=cc_address , subject=subject)

    # add text
    for text in body:
        attach_text(msg, text[0], text[1])

    # add files
    if len(files) != 0:
        for afile in files:
            attach_file(msg, afile)

    # send message
    send_email(server, username, password, msg, 0)

    # check for bcc
    if (bcc_address != ''):
        msg['Bcc'] = bcc_address
        send_email(server, username, password, msg, 1)

    print 'email sent'


def attach_text(msg, atext, mode):
# attach text
# attaches a plain text or html text to a message
    print "Attaching Text..."
    part = MIMEText(atext, get_mode(mode))
    msg.attach(part)


def get_mode(mode):
# util function to get mode type
    print "Getting Mode..."
    if (mode == 0):
        mode = 'plain'
    elif (mode == 1):
        mode = 'html'
    else:
        print 'error in text kind'
        print 'email cancled'
        # exit()
    return mode


def attach_file(msg, afile):
# attach file
# takes the message and a file name and attaches the file to the message
    print "Attaching Files..."
    part = MIMEApplication(open(afile, "rb").read())
    part.add_header('Content-Disposition', 'attachment', filename=afile)
    msg.attach(part)



#=============================== START OF MAIN ===============================

def main():
    name = sys.argv[1]
    contactEmail = sys.argv[2]
    subject = sys.argv[3]

    msg = """
Hello {0},

My name is Kyle Almryde. I am a participating researcher in the Psychology
101 experiment program. You indicated an interest in participating in the
kinds of research we do. I would like to invite you to participate in a study
of language and the brain that is being conducted by researchers in the
Department of Speech, Language, and Hearing Sciences.

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
     Because the MRI uses a magnet to make images, it is absolutely crucial
     that there is no ferromagnetic metal of any kind on or in your body at the
     time of the scan.  This includes body piercings and permanent retainers.
     This is for your safety.

2)   Anti-psychotic or anti-seizure medications:
     Although these medications are important for those who need them, we
     cannot enroll people who are currently taking any of these types of drugs.

3)  You are comfortable in tight spaces: We must place you inside the MRI in
    addition to placing several sensitive devices on and around your head,
    which can make some people who normally do not like tight spaces
    uncomfortable. It can be even worse for someone who is claustrophobic.

4)   Your age:  You must be age 50 or younger.


If you do not qualify for the MRI portion of the study, we would still like to
invite you to participate in the behavioral portion of our study, and you will
receive 3 experiment credits (just no pictures of your brain).

If you could give me some days and times when you are free for
approximately 1hr 30mins, I can schedule you for the behavioral testing
portion of our study. Additionally, if you have any questions, please do
not hesitate to ask.

Thank you for your interest in our study, we could not do our research without
you!

Best,

Kyle Almryde

--
Kyle R. Almryde, B.S.
Research Technician
University of Arizona | The Plante Lab
Speech Language, and Hearing Sciences
Office: +1 (520) 621-0108
Cell: +1 (760) 208-7827
kalmryde@email.arizona.edu\n
""".format(name)

    #to be tested...
    adresses = [contactEmail,'','']
    message = [[msg,0]]
    attachments = []
    # attachments = ["/Users/kylealmryde/Dropbox/Work-Projects/Misc/fMRI_checklist_fillable.pdf",
    #                "/Users/kylealmryde/Dropbox/Work-Projects/Misc/Hippa_consent_2013.pdf",
    #                "/Users/kylealmryde/Dropbox/Work-Projects/Misc/InformationForm_Feb2013.pdf",
    #                "/Users/kylealmryde/Dropbox/Work-Projects/Misc/Lang_Hand Form.pdf",
    #                "/Users/kylealmryde/Dropbox/Work-Projects/Misc/MRI_consent_2013.pdf"]

    compose_email(adresses,subject,message,attachments)

    #compose_email can take the following arguments:
    #   1. to recipients (separated by a comma)
    #   2. cc recipients (separated by a comma)
    #   3. bcc recipients (separated by a comma)
    #   4. subject
    #   5. a list with message and mode (plain txt or html)
    #   6. files to be attached



if __name__ == '__main__':
    main()


