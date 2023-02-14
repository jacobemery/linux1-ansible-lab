# Running Ansible Playbooks
## Follow these steps for an introduction to running Ansible Playbooks to automate your IBM LinuxONE virtual server's configuration.
If you have not yet connected to your LinuxONE virtual server via SSH, return to step 3 for either [Windows](./3_windows_connect.md) or [Mac](./3_mac_connect.md).
* Ansible is a powerful and flexible automation tool. Here are some reason it's really popular:
    - <b>Easy to read and understand:</b> beginner-friendly
    - <b>Powerful:</b> automate thousands of servers at a time.
    - <b>Agent-less:</b> nothing is installed on the managed servers, so easy set-up and low overhead.
    - <b>Free and open-source:</b> large community write modules and plugins to extend it further, like the [collection](https://www.ibm.com/support/z-content-solutions/ansible/) IBM created to automate z/OS with Ansible!
* These are just a few reasons that Ansible is now the go-to tool for server configuration. You are learning an extremely valuable skill here!
* Let's jump right in and get your hands dirty running Ansible, shall we?
## Running your First Ansible Playbook
* A `playbook` is the term for the executable file that contains the automation instructions for Ansible.
* Become the root user by executing the following command:
```
sudo -i
```
* WARNING: Becoming the root user is very dangerous for the integrity and security of the server because they have access to all commands. Tread carefully.
* To get you started as quickly as possible, we're going to first install git and then pull a set of pre-made playbooks for this lab by executing the following commands:
```
dnf install git -y
```
```
git clone https://github.com/jacobemery/linux1-ansible-lab.git
```
```
cd linux1-ansible-lab
```
* You should now be in the `/root/linux1-ansible-lab` directory.
* Do a quick `ls -la` to see what files you just pulled down from the internet:
```
ls -la
```
* You'll see a shell script called `setup.sh`. It's common to have a setup script accompany Ansible Playbooks since Ansible and this set of playbook's other dependencies must be installed first.
* In this case though, the setup script also runs the first Ansible playbook called `setup.yaml` as well. We'll talk more about what that playbook does after you run it.
* To run the setup script, use the following command:
```
./setup.sh
```
* Voila! That should've been relatively quick. You just automated a bunch of Linux administration tasks all at once. Pretty neat, right?
* So what did it do!?
* Let's first take a look at what's in the setup script:
```
cat setup.sh
```
* This is an extremely simple shell script, here's what the three lines do:
    * Install Ansible.
    * Install these playbooks' dependencies in 'requirements.yaml' from Ansible Galaxy, where community-created modules are stored.
    * Run the setup.yaml Ansible Playbook.
* This last line is nesting another set of tasks within this script, as it calls Ansible to run the first playbook automatically.
* So what does <i>that</i> playbook do?
## Understanding Ansible Playbooks
```
cat playbooks/setup.yaml
```
* As we discussed in the lecture section of this class, an Ansible Playbook is a series of declarative automation `tasks` that run against `hosts` (or servers).
* At the top of the playbook you can see that the host we are running this playbook on is the `localhost`, meaning itself, or sometimes referred to as the `Ansible Controller`. The controller is where Ansible is executed from. The controller can be managed by Ansible just like it would a remote target.
* The next line says 'become: true', this starts to get into how Ansible works a bit. Ansible uses SSH to connect to the target node as a user, who can then 'become' a super-user. So we are telling Ansible it must have super-user privileges to do these tasks.
* Then comes the list of tasks that run in order. Each task has a pattern that it follows:
    * `name`: The description of the task being done. This is what is printed in the terminal output. It can be anything, but the more descriptive, the easier it is to understand what the playbook is doing.
    * `tags`: An optional parameter which allows you to run pieces and parts of playbooks. More on tags later.
    * `module`: The type of task being run, i.e. 'ansible.builtin.package', is the name of the first task's module. This module can install, uninstall, and manage packages (or software) on the server. The modules are where the magic happens in a task.
    * `module parameters`: Each module has a set of parameters which are documented online (i.e. [copy module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)), this is where you tell the module what exactly what to do. For example, in the first task we have specified a list of two packages 'httpd' and 'firewalld', and that we want them to be in the 'present' state - meaning we want them to be installed on our system. If you changed that to 'absent' instead of 'present', Ansible would remove those packages.
    * `additional options`: There are other ways to manipulate the execution of these tasks, for example:
        * `Loops`, as in the second task.
        * `Conditionals`, as in the fourth task.
        * `Register`, to store variables for future use, as in the third task.
        * There are others, but those are the most common.
* This one playbook did in a few seconds what the labs from yesterday's course all in a few seconds. 
* Did you notice in the playbook how it first checked to make sure there wasn't already an index.html file as to avoid overwriting your work? But if this is someone's first class, an index.html file was copied since there wasn't one there already.
* Whether you were in the course yesterday or not, the Ansible playbook worked the same for everyone. This brings up an interesting and important concept in Ansible: `idempotency`.
* From the [Ansible documentation](https://docs.ansible.com/ansible/latest/reference_appendices/glossary.html), <b>"an operation is idempotent if the result of performing it once is exactly the same as the result of performing it repeatedly without any intervening actions."</b>
* Because the playbook was made to be idempotent you can be confident that successive runs of that playbook won't fail in error just because it was run twice.
* Try it out! Run the setup.yaml playbook again:
```
ansible-playbook playbooks/setup.yaml
```
* As you can see, the playbook ran perfectly smooth a second time!
* And since the setup.yaml playbook is idempotent, it doesn't matter if you were in yesterday's class or not. Now everyone's servers are in the same `state`. State changes are represented with colors:
    * ${\color{green}ok}$: when the server is already in the desired state and no action was performed.
    * ${\color{yellow}changed}$: when an action was performed (doesn't necessarily mean it is now in the desired state).
    * ${\color{cyan}skipping}$: when a task is explicitly skipped (usually because of a conditional).
    * ${\color{red}fatal}$: when there's an error, meaning Ansible could not achieve the desired state.
* Ansible does a <u>lot</u> of the work of making the playbooks idempotent for you, but it is not guaranteed, and sometimes requires tweaking. Newly written playbooks should be thoroughly tested for idempotency.
* If you weren't here for yesterday's course, open up a web browser and check out your brand new bare-bones website! Type this into a web browser to see it:
```
http://<ip-address>
```
* If you forgot your server's IP address, you can get it [here].(https://linuxone.cloud.marist.edu/#/instance).
* Make sure to type in 'http' not 'https', sometimes web browsers will automatically switch it to 'https'. If this happens, use Firefox.
## Review:
* Ok that was a lot of information thrown at you all at once! Hope you held onto your (red) hats.
* Let's review what you've learned so far:
    * Learned about why Ansible is so widely used
    * Ran your first Ansible Playbook
    * Learned the basic components of an Ansible Playbook
    * Learned the basic components of a task
    * Learned about the importance of idempotency

## You are now ready to move on to [step 5](./5_write_playbooks.md), where you will write your first playbook!