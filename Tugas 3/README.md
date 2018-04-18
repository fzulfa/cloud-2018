### 1. Membuat image container

#### Python dan Flask

Supaya dapat digunakan untuk menjalankan sistem reservasi, berikut langkah-langkah yang kami lakukan:

1. Buat Dockerfile baru.
2. Gunakan base Ubuntu 16.04.
3. Install python, python-pip, dan libmysqlclient-dev dengan apt-get.
4. Salin folder **reservasi** dari host ke dalam container.
5. Install **req.txt** menggunakan pip. **req.txt** berisi dependecy yang diperlukan untuk menjalankan sistem reservasi.
6. Atur container untuk menjalankan sistem reservasi begitu container dinyalakan.
7. Expose port 80 pada container.

Berikut hasil akhir Dockerfile:

    FROM ubuntu:16.04

    RUN apt-get update
    RUN apt-get install -y python
    RUN apt-get install -y python-pip
    RUN apt-get install -y libmysqlclient-dev
    RUN pip install --upgrade pip

    COPY reservasi reservasi/
    RUN pip install -r reservasi/req.txt

    CMD ["python", "reservasi/server.py"]

    EXPOSE 80


### 2. Membuat 3 worker

Kami membuat 3 buah node sebagai worker untuk menjalankan aplikasi Flask pada container masing-masing. Pertama-tama, kami menyiapkan 3 buah Dockerfile seperti di atas lalu memasukkannya ke dalam folder **worker1**, **worker2**, dan **worker3**. Folder **reservasi** juga ikut dimasukkan ke dalam tiga folder tersebut.

Untuk membuat container dari Dockerfile menggunakan Docker Compose, berikut langkah-langkah yang kami lakukan.

1. Buat **docker-compose.yml** dengan isi sebagai berikut:

        version: '3.3'

        services:
            worker1:
                build:
                    context: worker1/
            worker2:
                build:
                    context: worker2/
            worker3:
                build:
                    context: worker3/

2. Jalankan dengan Docker Compose.

        docker-compose up -d --build

Tiga buah worker berhasil dibuat meskipun web belum dapat dijalankan.


### 3. Load balancing

#### Nginx

Nginx akan digunakan sebagai load balancer untuk mendistribusikan request kepada worker yang telah kami buat sebelumnya. Kita dapat menambahkan image container nginx yang tersedia di Docker Hub.

1. Buat file baru bernama **default.conf** dengan isi sebagai berikut:

        upstream worker {
                server worker1;
                server worker2;
                server worker3;
        }
         
        server {
                listen 80;
                location / {
                        proxy_pass http://worker;
                }
        }

2. Edit **docker-compose.yml** dan masukkan image container nginx ke dalamnya.

        version: '3.3'

        services:
            worker1:
                build:
                    context: worker1/
            worker2:
                build:
                    context: worker2/
            worker3:
                build:
                    context: worker3/
            balancer:
                image: nginx
                ports:
                    - "9000:80"
                volumes:
                    - ./default.conf:/etc/nginx/conf.d/default.conf
                links:
                    - worker1:worker1
                    - worker2:worker2
                    - worker3:worker3

    * Container pada port 80 dapat diakses oleh host dengan port 9000.
    * **default.conf** pada host dimasukkan pada **/etc/nginx/conf.d/default.conf** pada container untuk mengkonfigurasi nginx.
    * Supaya nginx dapat mengakses IP address ketiga worker, service ketiga worker tersebut dimasukkan ke dalam `links`.


### 4. Database

#### MySQL

MySQL digunakan sebagai database sistem reservasi. Supaya ketiga worker dapat mengakses database, beberapa environment variable berikut diperlukan.

    username: userawan
    password: buayakecil
    nama database: reservasi

Berikut langkah-langkah yg selanjutnya kami lakukan:

1. Siapkan dump file.

    **reservasi.sql** dapat ditemukan di dalam folder **reservasi**. Salin ke folder yang sama dengan **docker-compose.yml**.

2. Edit **docker-compose.yml**.

        version: '3.3'

        services:
            db:
                image: mysql:5.7
                volumes:
                    - dbdata:/var/lib/mysql
                    - ./reservasi.sql:/docker-entrypoint-initdb.d/init.sql
                restart: always
                environment:
                    MYSQL_ROOT_PASSWORD: buayakecil
                    MYSQL_DATABASE: reservasi
                    MYSQL_USER: userawan
                    MYSQL_PASSWORD: buayakecil
            worker1:
                depends_on:
                    - db
                build:
                    context: worker1/
                environment:
                    DB_HOST: db
                    DB_NAME: reservasi
                    DB_USERNAME: userawan
                    DB_PASSWORD: buayakecil
            worker2:
                depends_on:
                    - db
                build:
                    context: worker2/
                environment:
                    DB_HOST: db
                    DB_NAME: reservasi
                    DB_USERNAME: userawan
                    DB_PASSWORD: buayakecil
            worker3:
                depends_on:
                    - db
                build:
                    context: worker3/
                environment:
                    DB_HOST: db
                    DB_NAME: reservasi
                    DB_USERNAME: userawan
                    DB_PASSWORD: buayakecil
            balancer:
                image: nginx
                ports:
                    - "9000:80"
                volumes:
                    - ./default.conf:/etc/nginx/conf.d/default.conf
                links:
                    - worker1:worker1
                    - worker2:worker2
                    - worker3:worker3
        volumes:
            dbdata:

    * `./reservasi.sql:/docker-entrypoint-initdb.d/init.sql` untuk memasukkan dump file ke dalam container. Dump file otomatis dijalankan saat container dibuat.
    * `environment` berisi environment variable yang diperlukan oleh ketiga worker maupun database.
    * Setiap worker dihubungkan ke service db menggunakan `depends_on` supaya IP address database dapat diakses.
    * Pada ketiga worker, `DB_HOST` berisi IP address database.
    * Volume `dbdata` untuk menyimpan semua perubahan pada database.

3. Konfigurasi selesai. Jalankan dengan Docker Compose.

        docker-compose up -d --build

Sistem reservasi dapat dijalankan oleh host pada http://localhost:9000.
