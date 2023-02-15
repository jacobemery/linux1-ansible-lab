# Writing Ansible Playbooks
## Follow these steps for an introduction to write your first Ansible Playbook.
If you have not yet run the setup playbook, return to [step 4](./4_run_playbooks.md).
* So now that you have a sense for what Ansible Playbooks can do, let's have you try your hand at writing one yourself!
* Let's pretend you're the Linux administrator for a small company that runs a website on their own servers.
* If changes need to be made to the website, it's probably not a good idea to edit the website directly, just in case a change that's introduced ends up crashing it.
* So let's set up a staging environment. That way we can catch breaking changes before they make it to the website. 
* If you're making changes to the website often, you'll want to an automated way of moving this new version of the website from staging to production.
* Ready to write?
## Creating your Playbook:
* If you're not there already, go to the git project's root directory.
```
cd /root/linux1-ansible-lab
```
* Let's start by creating a new file from the /root/linux1-ansible-lab directory, with the text editor `vi`:
```
vi stage2prod.yaml
```
* If you need a vi refresher:
    * `vi` is short for 'visual', and it is the basic text editor of the Linux terminal.
    * Use `vi <filename>` to start editing a file.
    * To make changes, press the `i key` to enter 'insert' mode.
    * Use the `arrow keys` to move the cursor around the screen.
    * When you are done editing, hit `Esc` to exit 'insert' mode, and then type `:wq` to 'write' (save) and 'quit' vi.
    * To quit without saving, use `:q!` instead.
* In vi, add the following lines at the top of the file:
```
- hosts: localhost
  tasks:
    - name: Copy staging environment to production.
      ansible.builtin.copy:
        src: /var/www/html/stage/
        dest: /var/www/html/
```
* Read through this task and see if you can understand how this playbook works so far. [Here](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)'s the copy module's documentation if you'd like more insight into the parameters for this module.
* But there's an important step missing here. If we copy out this file, it will replace and delete the old version. That's no good! If something goes wrong, we need to be able to quickly revert back to a backup, and we don't want to save over all your hard work in the index.html file.
* So there's one more task to add before we save and quit vi...
## Writing your Playbook
* Using the [copy module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html), write a task, <b><i>before</i></b> the one already there, that copies `/var/www/html/` to a directory for safe keeping - `/root/site/backup/`
* A quick helpful note on YAML syntax:
    * Ansible playbooks are written in `YAML` (which stands for Yet Another Markup Language, I wish that was a joke). More on YAML syntax [here](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html).
    * These playbooks use a double space instead of a tab for each indentation.
    * YAML is great because it doesn't have a lot of special characters, like [JSON](https://builtin.com/software-engineering-perspectives/yaml-vs-json) does.
    * But just like other markup languages, it has some syntax quirks that can take some getting used to. Particularly with `indentation`.
    * So just a warning: the indentation of each line must be exactly correct or else the playbook won't work. Follow the indentation that's already provided for you.
    * If you're really stuck, please ask and I'll help you!
* When you are ready, hit the `Esc` key to exit 'insert' mode, and then type `:wq` to save and quit vi.
## Testing your playbook
* Before you test your playbook, run these one-time commands to set things up:
```
mkdir -p /root/site/backup/
```
```
mkdir /var/www/html/stage/
```
Feel free to change the contents in-between the quotes in this next one, if you'd like:
```
echo "stage2prod test" > /var/www/html/stage/index.html
```
* Ok, now let's test out your playbook! Ready?
```
ansible-playbook stage2prod.yaml
```
* How'd it go? Did it work?
* If it did, nice work!! If not, that's ok! It can be tough to get it right. 
* Here are some `troubleshooting tips` if you encountered an error:
    * Read the error message carefully and completely. They're not always perfect, but they at least point you in the right direction most of the time.
    * Re-run the playbook with the verbosity the '-v' option to get more debugging information (more v's give more info). For example:
        ```
        ansible-playbook stage2prod.yaml -vvv
        ```
    * Double-check your indentation, especially if it mentions a syntax error. Match it up with the task that's already there, or use the site.yaml file as a reference.
    * If you need to stop a playbook mid-run, hit the `Ctrl+C` keys to terminate it.
    * If you're stumped, don't wait too long before asking me for help in the webex!
* Hopefully you were able to get it working! It can be sneakily difficult sometimes.
* Now you have a system in place for staging a new version of your site at /var/www/html/stage/. You can now edit, test, and check it out there first, and then when it's ready, automatically deploy the new version and backuping the old one. Pretty cool, eh?
## Webiste Contest
* To encourage you to have some fun with customizing your new proto-type website, I'll be `giving away 150 BluePoints` to the owner of the best website at the end of the day today! 
* So go wild! Be creative! Fill your index.html file with text, headers, colors, images! Customize to your hearts content! Do whatever you want with your website! Post cat gifs, memes, poetry, anything!
* Refer to this [HTML cheat sheet](https://web.stanford.edu/group/csp/cs21/htmlcheatsheet.pdf) for a quick guide on getting the most out of your customization:
```
vi /var/www/html/stage/index.html
```
* And once you're done editing and you've checked out your staged website via web browser...
    ```
    http://<ip-address>/stage/
    ```
    ...or at least with `curl`...
    ```
    curl http://<ip-address>/stage/
    ```
* ...and you're ready to make the new version go live, run this command to push to production from anywhere on the server:
```
ansible-playbook /root/linux1-ansible-lab/stage2prod.yaml
```
* And once you have your website into a state you're proud of, send your IP address in the webex chat for everyone else to check it out! And at the end of the day I'll send that person `150 BluePoints`!
## Review
* Hopefully you got creative with your new website! You also created some nifty automation with Ansible Playbooks!
    * You wrote your first Ansible playbook, congrats! 
    * You have your very own website
    * You created a simple staging-to-production pipeline for your website

## You are now ready to move on to [step 6](./6_automate_restore.md), where you will continue to improve your website's automation!