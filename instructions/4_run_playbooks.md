# Running Ansible Playbooks
## Follow these steps for an introduction to running Ansible Playbooks to automate your IBM LinuxONE virtual server's configuration.
If you have not yet connected to your LinuxONE virtual server via SSH, return to step 3 for either [Windows](./3_windows_connect.md) or [Mac](./3_mac_connect.md).
* Ansible is a powerful and flexible automation tool. Here are some reason it's really popular:
    - Easy to read and understand - beginner-friendly
    - Free and open-source - large community write modules and plugins to extend it further, like the [collection](https://www.ibm.com/support/z-content-solutions/ansible/) IBM created to automate z/OS with Ansible!
    - Powerful - automate thousands of servers at a time
* These are just a few reasons that Ansible is now the go-to tool for server configuration. You are learning an extremely valuable skill here!
* Let's jump right in and get your hands dirty running Ansible, shall we?
## Running your First Ansible Playbook
* A `playbook` is the term for the executable file that contains the automation instructions for Ansible.
* To get you started as quickly as possible, we're going to first install git and then pull a set of pre-made playbooks for this lab by executing the following commands:
```
sudo dnf install git -y
```
```
git clone https://github.com/jacobemery/linux1-ansible-lab.git
```
```
cd linux1-ansible-lab
```
* You should now be in the `/home/linux1/linux1-ansible-lab` directory.
* Do a quick `ls -la` to see what files you just pulled down from the internet:
```
ls -la
```
* You'll see a shell script called `setup.sh`. It's common to have a setup script accompany Ansible Playbooks since Ansible and this set of playbook's other dependencies must be installed first.
* In this case though, the setup script also runs the first Ansible playbook called `1_setup.yaml` as well. We'll talk more about what that playbook does after you run it.
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
    * Run the 1_setup.yaml Ansible Playbook.
* This last line is a nesting of sorts, because 