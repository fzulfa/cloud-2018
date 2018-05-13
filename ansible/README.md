## 1. VM

Kami membuat tiga buah virtual machine menggunakan *Vagrant*. Dua buah sebagai worker dengan *Ubuntu 16.04*. Satu buah sebagai database server dengan *Debian 9*.

Berikut isi dari file *hosts*.

```
[worker]
worker1 ansible_host=192.168.33.11 ansible_ssh_user=vagrant ansible_become_pass=vagrant
worker2 ansible_host=192.168.33.12 ansible_ssh_user=vagrant ansible_become_pass=vagrant

[db]
db ansible_host=192.168.33.13 ansible_ssh_user=vagrant ansible_become_pass=vagrant
```

## 2. Provisioning

Menggunakan *Ansible*, kami melakukan provisioning pada dua buah worker sebagai berikut.

```
- hosts: worker
  tasks:
    - name: Install server
      become: yes
      apt: name={{ item }} state=latest update_cache=true
      with_items:
        - nginx
        - php
        - composer
        - git
    - name: Clone repository
      git:
        repo: 'https://github.com/udinIMM/Hackathon.git'
        dest: ~/Hackathon
    - name: Copy .env
      copy: src=./.env dest=~/Hackathon/.env
    - name: Set ngin root
      copy: src=./default dest=/etc/nginx/sites-available/default
```

Provisioning mulai dengan menginstal *nginx*, *php*, *composer*, dan *git*. Setelah semua berhasil diinstal, *Ansible* akan melakukan *git clone* pada repository [https://github.com/udinIMM/Hackathon.git](). Terakhir, *Ansible* mensalin file *.env* dan *default* masing-masing untuk melakukan sambungan ke database dan mengkonfigurasi *nginx*.

Bagian berikut dari *.env* berisi informasi untuk mengkases database.

```
DB_CONNECTION=mysql
DB_HOST=
DB_PORT=3306
DB_DATABASE=
DB_USERNAME=regal
DB_PASSWORD=bolaubi
```

Berikut isi dari *default*.

```
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        
        root ~/Hackathon;
        index index.html index.htm index.nginx-debian.html;
        
        server_name _;
       
        location / {
                try_files $uri $uri/ =404;
        }
}
```

Sementara itu, berikut provisioning yang dilakukan pada database.

```
- hosts: db
  tasks:
    - name: Install database
      become: yes
      apt: name={{ item }} state=latest update_cache=true
      with_items:
        - mysql-server
    - name: Create a new user
      mysql_user:
        name: regal
        password: bolaubi
        priv: '*.*:ALL'
        state: present
```

Provisioning termasuk menginstal *MySQL* server serta membuat user baru dengan username *regal* dan password *bolaubi*.
