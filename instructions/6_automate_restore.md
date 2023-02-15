# Automating Restore-from-Backup
## Follow these steps to improve your first Ansible Playbook, adding functionality to restore a broken website from your backup.
If you have not yet written the stage2prod.yaml playbook, return to [step 5](./5_write_playbooks.md).
* So you have automation to deploy your website from the staging environment, and it even creates a backup of your production website first.
* But what if the deployment goes wrong?
* It would be extremely helpful to have fast automation to restore your website from its backup, don't you think?
* Let's open your stage2prod playbook again:
```
vi stage2prod.yaml
```
* Add the following <i><b>after</i></b> the last task. Make sure to copy over the indentation too (the spaces before 'block'):
```
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
* So what did we just add? 
* Two tasks to help us test if the website is working, and to restore it from the backup if those tests fail.
* Notice the `block` and `rescue` lines? If any of the tasks in the `block` fail, it will execute the `rescue` section; otherwise it will not run the `rescue` section.
* Notice how I said 'any of the tasks in the block' but we seem to only have one task in this block, so what's going on here?
## Ansible Roles
* This `include_role` module is special because it is nesting additional tasks that will come from the 'restore' role.
* `Roles` help us to organize tasks into functional groups. Roles are usually created if those tasks need to be run in several different playbooks which all need the same set of tasks completed.
* So let's create the 'restore' role together, hopefully it will make more sense in practice.
* From the project's root directory (/root/linux1-ansible-lab), run the following command to create the necessary files and directories:
```
mkdir -p roles/restore/tasks && \
touch roles/restore/tasks/test.yaml roles/restore/tasks/restore_from_backup.yaml
```
* The `&&` chains multiple commands together. Here are the directories and files it created:
```
roles
 |_restore
    |_tasks
       |_test.yaml
       |_restore_from_backup.yaml
```
* This matches the required directory structure for roles.
* Let's now add some tasks to the `test.yaml` file:
```
vi roles/restore/tasks/test.yaml
```
* Paste in the following:
```
- name: Check HTTP status code, fail if not OK (code 200).
  tags: http_status
  warn: false
  ansible.builtin.command: "curl -s -o /dev/null -w '%{http_code}' http://localhost/"
  register: http_status
  failed_when: http_status.stdout != '200'

- name: Check contents of website's main index
  tags: index
  ansible.builtin.command: "cat /var/www/html/index.html"
  register: cat_index_check

- name: Check contents of website's homepage with curl, fail if not the same as previous
  tags: index
  ansible.builtin.command: "curl http://localhost"
  register: curl_index_check
  failed_when: cat_index_check.stdout != curl_index_check.stdout
```
* So what does all this do? It's a bit complicated, so let's go task-by-task:
    * First, we use the `command` module to run a terminal command directly, in this case, a `curl` command. Then we filter the output so that it returns only the [HTTP status code](https://www.semrush.com/blog/http-status-codes/?kw=&cmp=US_SRCH_DSA_Blog_EN&label=dsa_pagefeed&Network=g&Device=c&utm_content=622080552390&kwid=dsa-1754723155433&cmpid=18348486859&agpid=145169429990&BU=Core&extid=60113851316&adpos=&gclid=CjwKCAiA_6yfBhBNEiwAkmXy525fWG7dbu1RmmgnLMDdt_J4jXij5pmM89U7_Ue7F8nXPSmOVX_JeBoCFjEQAvD_BwE). It then has a `failed_when` conditional, which tells Ansible to make the task ${\color{red}fail}$ if the status code is <i>not</i> 200 (200 meaning all is well, so it will fail when all is <i>not</i> well). 
    * Next, we again use the `command` module, but this time with `cat` to check the contents of the /var/www/html/index.html file. This output is then registered (or stored) as a variable called `cat_index_check`, which will then be compared with the output of the following task.
    * Finally, we run the `command` module with `curl` again, but this time to get the contents of the homepage directly from HTTP, and save it as `curl_index_check`. We then use another `failed_when` conditional to tell Ansible to make the task ${\color{red}fail}$ if `cat_index_check` and `curl_index_check` are not exactly the same.
* Did that all make sense? If not, let me know in the Webex.
* Notice that we also didn't need to specify the `hosts` parameter at the beginning of this file, like we did in the playbook. This is because a `role` will be run in <i>many different playbooks</i>. The playbook holds the information about <i>where</i> this role will be run, so it's not needed here.
* You can now save and quit `vi`: `Esc` key to leave 'insert' mode, then `:wq` to save and quit.
* We're almost done with our role! But we still need the `restore_from_backup.yaml` file to be filled in so that if anything from `test.yaml` fails, we'll be able to revive our website.
* So let's open up the `restore_from_backup.yaml` file:
```
vi roles/restore/tasks/restore_from_backup.yaml
```
* And paste in the following:
```
- name: Restore website from backup.
  tags: restore
  copy: 
    src: /root/site/backup/
    dest: /var/www/html/

- name: Restart httpd service.
  tags: restart
  service:
    name: httpd
    state: restarted
```
* Did you notice that I didn't use the fully-qualified module names? That's because the 'ansible.builtin' modules are installed by default, and don't need the entire module name. For example, instead of `ansible.builtin.copy`, only `copy` is required. Other modules that are not part of 'ansible.builtin' require the full module name to be specified.
* So what do these tasks do? They're a little more self explanatory than the others, but let's go task-by-task:
    * First, because these tasks are only run if the tests failed, we know something is already wrong. So we restore from our backup copy in hopes of returning to the safety of a previously working website. This will overwrite the production webpage, but remember that staging has our back there.
    * Second, we restart the httpd service, this is a catch-all for many different problems that arise. The good 'ol "did you try turning it off and on?"
* You can now save and quit `vi`: `Esc` key to leave 'insert' mode, then `:wq` to save and quit.
* Now that you have an Ansible role configured, that is referenced in your stage2prod playbook, let's run that playbook to test it out:
```
ansible-playbook stage2prod.yaml
```
* Did the playbook run ok? 
* If not, check out the Ansible documentation's [troubleshooting guide](https://docs.ansible.com/ansible-tower/2.2.0/html/administration/troubleshooting.html) for help. If after a short time, you can't get it figured out, please ask in the Webex.
* If your playbook successfully ran, great!
* Your playbook may have run without any errors though, so you didn't really get to see whether or not the restore_from_backup part of your playbook actually works. 
* How can we know for sure that your restoration process will work when you need it most?
* Well, like any good system administrator, we have to test it! That's where we're headed next...
* But first, let's review what we learned in this step:
## Review:
* Learned about `roles` and what they are used for
* Created a `role` to automte testing and restoring from backup upon failure
* Learned about more complicated task parameters like `failed_when` and `register`
* Incorporated that role into a playbook

## Nice work! You are ready to move on to [step 7](./test_restore.md), where you will further test your restoration automation.
