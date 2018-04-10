### 1. Buatlah Vagrantfile sekaligus provisioning-nya untuk menyelesaikan kasus.

#### Membagi IP address

1. Load balancer (nginx): 192.168.2.2
2. Worker 1 (apache2): 192.168.2.3
3. Worker 2 (apache2): 192.168.2.4


#### Instalasi nginx

Langkah-langkah yang kami lakukan:

1. Buat dan masuk ke folder baru.

        mkdir loadbalancer
        cd loadbalancer

2. Inisialisasi Vagrant.
        
        vagrant init

3. Atur box yang akan digunakan pada Vagrantfile.
        
        config.vm.box = "hashicorp/precise64"

3. Atur private address pada Vagrantfile supaya dapat diakses dari luar.
        
        config.vm.network "private_network", ip: "192.168.2.2"

4. Buat provisioning untuk menginstall nginx.

        apt-get update
        apt-get install -y nginx

5. Jalankan Vagrant dan lakukan provisioning.
        
        vagrant up --provision


#### Instalasi apache2 sebagai worker

Langkah-langkah yang kami lakukan:

1. Buat dan masuk ke folder baru.

        mkdir worker1
        cd worker1

2. Inisialisasi Vagrant.
        
        vagrant init

3. Atur box yang akan digunakan pada Vagrantfile.
        
        config.vm.box = "hashicorp/precise64"

3. Atur private address pada Vagrantfile supaya dapat diakses dari luar.
        
        config.vm.network "private_network", ip: "192.168.2.3"

4. Buat provisioning untuk menginstall apache2.

        apt-get update
        apt-get install -y apache2

5. Jalankan Vagrant dan lakukan provisioning.
        
        vagrant up --provision

#### Menggunakan 2 worker

Kami membuat satu lagi worker di dalam folder `worker2` dengan cara yang sama seperti di atas. Perbedaanya worker kedua memiliki private address 192.168.2.4. Untuk dapat membedakan dua worker tersebut kita dapat mengubah `/var/www/index.html` masing-masing worker. Dua worker dapat diakses oleh browser pada alamat 192.168.2.3 dan 192.168.2.4.


#### Konfigurasi nginx untuk load balancing

1. Setelah masuk dengan `vagrant ssh`, buka file konfigurasi nginx.

        nano /etc/nginx/sites-available/default

2. Ubah konfigurasi seperti berikut.

        upstream worker {
                server 192.168.2.3:80;
                server 192.168.2.4:80;
        }
        
        server {
                listen 80 default_server;
                listen [::]:80 default_server;
                
                root /var/www/html;
                index index.html index.htm index.nginx-debian.html;
                
                server_name _;
                
                location / {
                        try_files $uri $uri/ =404;
                        proxy_pass http://worker;
                }
        }

3. Restart nginx.

        service nginx restart

`upstream worker` berisi alamat worker yang sudah kita buat sebelumnya. Perintah `proxy_pass http://worker` nantinya akan meneruskan request ke 192.168.2.2 ke alamat worker. Ketika diakses melalui browser dan dilakukan refresh berulang akan terlihat worker yang terus berganti.


#### Menerapkan algoritma load balancing

1. Round-robin (default)

        upstream worker {
                server 192.168.2.3:80;
                server 192.168.2.4:80;
        }

2. Least-connected

        upstream worker {
                least_conn;
                server 192.168.2.3:80;
                server 192.168.2.4:80;
        }

3. IP-hash

        upstream worker {
                ip_hash;
                server 192.168.2.3:80;
                server 192.168.2.4:80;
        }


### 2. Analisa apa perbedaan antara ketiga algoritma tersebut.


### 3. Biasanya pada saat membuat website, data user yang sedang login disimpan pada session. Sesision secara default tersimpan pada memory pada sebuah host. Bagaimana cara mengatasi masalah session ketika kita melakukan load balancing?

