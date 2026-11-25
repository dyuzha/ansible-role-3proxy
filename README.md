"3proxy" Ansible Role
=========

Deploy and configure HTTP and SOCKS proxy server "3proxy"

Requirements
------------

Remotes:
- Based on Debian OS
- Internet connection

Role Variables
--------------

```
# 3Proxy server version
proxy3_version: 0.9.4

# Port of HTTP proxy
proxy3_http_port: 3128

# Port of SOCKS proxy
proxy3_socks_port: 1080

# System user ID and Group ID
proxy3_system_group_id: 200
proxy3_system_user_id: 201

# List of DNS servers
proxy3_dns:
  - 1.1.1.1
  - 1.0.0.1

# true if you want use the Uncomplicated Firewall
# if false you may need to use other firewall
proxy3_use_ufw: false

# Build essential apt version
proxy3_build_essential_version: latest

# Clients of proxy server (accept all connections if empty or undefined)
proxy3_clients:
  - name: client0
    password: qwe123
```

Dependencies
------------

- The make utility needed on the target hosts
- Ansible community module 'community.general.make' must be installed
- Ansible community module 'community.general.ufw' must be installed

Example Playbook
----------------

```
- hosts: servers
  roles:
  - role: 3proxy-ansible-role
```

License
-------

MIT
