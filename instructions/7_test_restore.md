# Testing your Restoration Process
## Follow these steps to test the restoration automation process you've created.
If you have not yet created your 'restore' role, return to [step 6](./6_automate_restore.md).

* So we have an Ansible role for restoring from a backup, but are we sure it'll work when we need it to?
* For testing purposes, let's first create a separate playbook for just the testing and restoring part of your staging-to-production playbook:
```
vi test_site.yaml
```
* And paste in the following, a snippet of the playbook 'stage2test', but just the test and restore tasks.
```
- hosts: localhost
  tasks:
    - block:
      - name: Test the production site.
        tags: test
        ansible.builtin.include_role:
          name: restore
          tasks_from: test.yaml

      rescue:
      - name: If tests failed, restore from backup.
        tags: restore
        ansible.builtin.include_role:
          name: restore
          tasks_from: restore_from_backup.yaml
```
* Save and quit vi, you have that locked into memory yet?
* Before we run this playbook, you may have noticed a ${\color{purple}warning}$ about using the 'get_url' module when running one of the tasks before. Let's silence that warning, since it isn't helpful in this case, and it gives us a good moment to talk about an important file: `ansible.cfg`.
    * The 'ansible.cfg' file hosts configuration settings either globally for the entire system, or just for a set of playbooks.
    * This file is normally extremely important for customizing your environment when running playbooks, we've just been working with default settings so far.
    ```
    echo -e "[defaults] \ncommand_warnings=False" > ansible.cfg
    ```
* Ok , now we're ready to test out our playbook to make sure the restoration process works!
* Let's break some things, shall we?
## Testing Restoration from Backup
* WARNING: In a real production environment, these tests would be run on the staging environment (and probably a 'development' environment too) beforehand, but for simplicity's sake, we're going to test them live.
* One pretty quick way we can test if the role is working as intended would be to stop the httpd service. Let's try that now:
```
systemctl stop httpd
```
* Now that the web server is stopped, the restoration process should be triggered this time. Let's test it:
```
ansible-playbook test_site.yaml
```
* Your restoration process worked if you saw a ${\color{red}fatal}$ error code, and instead of stopping there, it ran 'TASK [If tests failed, restore from backup.]' instead, and the following tasks ran with ${\color{yellow}changed}$ status. If a backup had already been restored previously, then the second-to-last task may have ran with ${\color{green}ok}$ status.
* Let's make sure that httpd was restarted properly:
```
systemctl status httpd
```
* Hopefully that worked and httpd is back online!
* Now... come to think of it, wouldn't it be nice if after the restore_from_backup tasks ran, the `tests` tasks also ran again? That way you can be sure that either the restoration process worked and the backup was restored OR know immediately that the restoration process failed and emergency action is necessary.
* Let's do that now:
```
vi test_site.yaml
```
* Now `copy` the whole 'test the production site' task from the `block` section and `paste` it in the `rescue` section, after the 'If tests failed, restore from backup' task.
* Make sure to line up the indentation with what's already there. Double check it.
* Let's again bring down the httpd service:
```
systemctl stop httpd
```
* And again run the playbook:
```
ansible-playbook test_site.yaml
```
* If all goes well, we won't have to manually test if everything is working after our 'rescue' tasks run anymore. We can be confident in our automation to check certain things for us.
* BUT, how do we know that the rescue tasks' <i>failure</i> conditions are working properly?
* It's important to know when a restoration was attempted and <i>failed</i>, so that immediate human intervention can take place.
* If a failure happens silently, and looks like it was rescued and all is well, we'll only notice the website's down when customers come calling. Not great!
* So, are you ready to <i>really</i> break things?
## Testing the Tests
* Let's `uninstall httpd` completely, so as to prevent our tests from working. Obviously we could easily check that the package is installed, but this is to <i>simulate</i> a <b>catastrophic</b> crash of the site that requires immediate human intervention. 
* i.e. something happened that we weren't prepared for with our current tests that ended up crashing the site.
```
dnf remove httpd -y
```
* Now run the test playbook again, this time the restoration process will run, but it should fail:
```
ansible-playbook test_site.yaml
```
* Hopefully that worked, and <i>worked</i> in this case means it <i>failed</i>.
* When things are really broken, we want to make sure alarm bells will sound. 
* This test was to make sure that IF a catastrophic crash that cannot be remedied by our current tests does occur, we get an error. You could then use that failure to, for example, trigger an email to send to the website admin notifying them that the website is down.
## Website Down!
* Since <i>you</i> are the website's admin, let's pretend you just received an email notifying you that the website is down:
```
To: on-call-admin@widgets.com
From: no-reply@widgets.com
Subject: URGENT - Website Down!!!!

Attention on-call admin, 

This is an automated report with an urgent message:
The website was reported 'down' at: 
11:11:11 AM on February 15, 2023.

Restoration from backup failed.

Your immediate action is required.

Help us on-call-admin, you're our only hope!
```
* You see the notification and click on it. Pausing that video you were watching.
* Your eyes widen... reading. You let out a gasp, oh no! Your face gets hot, your heart starts pumping faster, mind racing!!! 
* Then you remember: 'wait I have automation for this.' A sense of calm washes over you, shoudlers relax, eyes sharpen.
* We'll be ok. Let's do this...
* What's the first thing you do?
* Open a web browser and go to the website:
```
http://<ip-address>
```
* Is the website still down? Was this a false positive? NO.
* What's next... you SSH to the server and check httpd status.
```
systemctl status httpd
```
* Uh oh, this is bad! httpd could not be found! Who would uninstall httpd!?
* Gotta quickly reinstall it:
```
dnf install httpd -y
```
* Once that finishes, you scramble to type in the restoration playbook command:
```
ansible-playbook test_site.yaml
```
* Did it work? Are you in the clear?
* If the playbook ran successfully, check the website:
```
http://<ip-address>
```
* You should be back online. PHEW!
* Nice work!! You saved the day.
* That's why it's important to create backups, create processes to restore those backups, test those restoration processes, and then thoroughly test those tests. 
* And that can all be automated with Ansible!
* I hope you're getting a sense for how powerful of a tool Ansible is, and of its potential!
* This is barely scratching the surface of its many uses.

## Review
* Learned about the `ansible.cfg` file for Ansible settings.
* Tested our restoration automation by breaking some things.
* Broke things even further to simulate a crash that the restoration process was not prepared for. And tested to make sure it gave a true negative.
* Jumped into action as the website admin and saved the website!
## More Ansible Labs:
* If you're hungry for more Ansible, here are some resources for you:
    * [Free labs](https://www.redhat.com/en/interactive-labs/ansible) from Red Hat, the creators of Ansible. I'd recommend starting with the "Writing Your First Playbook" lab.
    * [Video series](https://www.youtube.com/watch?v=3RiVKs8GHYQ) from YouTuber 'Learn Linux TV' - the best hands-on online tutorial I've found for learning Ansible.
## Hands-On Lab Complete!
* Nice work!! If you've made it this far, you did some serious automating!
* I hope this tutorial was helpful and interesting for you.
* You will have access to this virtual server until February 24, but you can request a two-week extension by emailing linux1@us.ibm.com
* If you have comments, questions, feedback, concerns, I'd love to hear them! 
* Please reach out to me at jacob.emery@ibm.com

## Don't forget to send your IP addresses in the Webex for a chance to win 150 BluePoints!
