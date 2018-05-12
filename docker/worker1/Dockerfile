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
