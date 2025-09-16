# Ansible Workspace: Windows Edition

## Setup

```bash
~/workspace $ python3 -m venv ./venv
~/workspace $ source ./venv/bin/activate
~/workspace (venv) $ hash -r
~/workspace (venv) $ pip install -r ./requirements.txt
~/workspace (venv) $ hash -r
~/workspace (venv) $ source ./env
~/workspace (venv) $ ansible-galaxy install -r ./requirements.yml
```

## Usage

```bash
~/workspace (venv) $ ansible-playbook ./site.yml
```
