preparing usbasp koerkana:

    ansible-playbook -i hosts.ini general-setup.yml
    ansible-playbook -i hosts.ini koerkana-addons.yml


run specific segments:

    ansible-playbook -i hosts.ini koerkana-addons.yml --tags "autossh,whatelse"



run random commands:

    ansible -i hosts.ini myservers:23428 -l *koerkana3* -u myuser -s -a "/usr/local/bin/blinkleds.py"



-----------------------------------------------------------------------------

random notes:

ansible -vvvv all -i hosts.ini -m ping --user root

print some info:

ansible -v -i hosts.ini all -m setup
